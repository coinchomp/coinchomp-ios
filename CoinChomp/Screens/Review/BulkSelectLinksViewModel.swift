//
//  BulkSelectLinksViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/20/21.
//

import Foundation

enum IntermediateReviewState : Int {
    case Reject = 0
    case Approve = 1
    case ManuallyReview = 2
}

class BulkSelectLinksViewModel : ObservableObject {

    @Published var links : [Link] = []
    @Published var linksNeedingManualReview : [Link] = []
    @Published var reviewStates : [String:IntermediateReviewState] = [:]
    @Published var installed : Bool = false
    @Published var buttonTitle : String = ""
    @Published var errorMessage : String = ""
    @Published var showingManualReview = false
    @Published var isBusy = false

    
    func prepareData(){
        guard self.links.count == 0 else { return }
        LinkService.shared.getLinksAwaitingReview(){
            [weak self] (links, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let links = links {
                self?.addLinks(remoteLinks: links)
                self?.initializeReviewStates()
            }
        }
        LinkService.shared.fetchFlaggedLinks { [weak self] (links, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let links = links {
                self?.addLinks(remoteLinks: links)
                self?.initializeReviewStates()
            }
        }
    }
        
    func addLinks(remoteLinks: [Link]){
        for remoteLink in remoteLinks {
            var canAddLink = true
            for localLink in self.links {
                if remoteLink == localLink {
                    canAddLink = false
                    break
                }
            }
            if canAddLink {
                self.links.append(remoteLink)
            }
        }
    }
    
    func initializeReviewStates(){
        reviewStates.removeAll()
        var rejected = 0
        var reviewed = 0
        for link in links {
            if link.collectionMethod == CollectionMethod.UserSubmitted ||
                link.isFlagged == true {
                reviewStates[link.linkID] = IntermediateReviewState.ManuallyReview
                reviewed = reviewed + 1
            } else {
                reviewStates[link.linkID] = IntermediateReviewState.Reject
                rejected = rejected + 1
            }
        }
        if reviewed == 0 {
            buttonTitle = "Reject \(rejected)"
        } else if rejected == 0 {
            buttonTitle = "Review \(reviewed)"
        } else {
            buttonTitle = "Reject \(rejected), Review \(reviewed)"
        }
    }
    
    func reviewStateForLinkID(_ linkID: String) -> IntermediateReviewState? {
        return reviewStates[linkID]
    }
    
    func tappedLink(_ link: Link){
        // always manually review user submitted links
        guard link.collectionMethod != .UserSubmitted else { return }
        guard link.isFlagged != true else { return }
        guard var value = reviewStates[link.linkID]?.rawValue else { return }
        value+=1
        if value>2 {
            value = 0
        }
        if link.collectionMethod == .Scrape {
            if IntermediateReviewState(rawValue: value) == IntermediateReviewState.Approve {
                value+=1
            }
        }
        reviewStates[link.linkID] = IntermediateReviewState(rawValue: value)
        updateUI()
    }
    
    func tappedProcessLinks(){
        isBusy = true
        processLinks()
    }
    
    private func processLinks(){
        var rejected : [String] = []
        var approved : [String] = []
        for (key, state) in reviewStates {
            if(state == IntermediateReviewState.Approve){
                approved.append(key)
            }else if(state == IntermediateReviewState.Reject){
                rejected.append(key)
            }
        }
        if rejected.count > 0 {
            processRejectedLinkIDs(rejected: rejected)
            return
        }
        if approved.count > 0 {
            processApprovedLinkIDs(approved: approved)
            return
        }
        
        self.updateUI()
        self.isBusy = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            // any remaining links need to be manually reviewed
            if self.links.count > 0 {
                self.showingManualReview = true
            }
        })
    }
    
    private func processApprovedLinkIDs(approved : [String]){
        guard let user = AuthService.shared.currentUser else { return }
        guard user.roles.contains("editor") || user.roles.contains("admin") else { return }
        if(approved.count > 0){
            var data : [String:Any] = [:]
            data["userID"] = user.userID
            var linkData : [[String:String]] = []
            for link in self.links {
                for approvedLinkID in approved {
                    if link.linkID == approvedLinkID {
                        var thisLinkData : [String:String] = [:]
                        thisLinkData["linkID"] = approvedLinkID
                        thisLinkData["sourceID"] = link.sourceID
                        linkData.append(thisLinkData)
                    }
                }
            }
            data["linkData"] = linkData
            DatabaseService.shared.bulkApproveLinks(data: data){
                [weak self] (succeeded, errorMessage) in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                } else if succeeded == false {
                    self?.errorMessage = "There was a problem"
                } else if succeeded == true {
                    self?.errorMessage = ""
                    if let links = self?.links {
                        var filteredLinks : [Link] = links
                        for approvedLinkID in approved {
                            self?.reviewStates.removeValue(forKey: approvedLinkID)
                            filteredLinks = filteredLinks.filter {
                                $0.linkID != approvedLinkID
                            }
                        }
                        self?.links = filteredLinks
                    }
                }
                DispatchQueue.main.async {
                    self?.updateUI()
                    self?.isBusy = false
                }
                //self?.processLinks()
            }
        }
    }
    
    private func processRejectedLinkIDs(rejected : [String]){
        guard let user = AuthService.shared.currentUser else { return }
        guard user.roles.contains("editor") || user.roles.contains("admin") else { return }
        if(rejected.count > 0){
            var data : [String:Any] = [:]
            data["linkIDs"] = rejected
            data["userID"] = user.userID
            DatabaseService.shared.bulkRejectLinks(data: data){
                [weak self] (succeeded, errorMessage) in
                    if let errorMessage = errorMessage {
                        self?.errorMessage = errorMessage
                    } else if succeeded == false {
                        self?.errorMessage = "There was a problem"
                    } else if succeeded == true {
                        self?.errorMessage = ""
                        if let links = self?.links {
                            var filteredLinks : [Link] = links
                            for rejectedLinkID in rejected {
                                self?.reviewStates.removeValue(forKey: rejectedLinkID)
                                filteredLinks = filteredLinks.filter {
                                    $0.linkID != rejectedLinkID
                                }
                            }
                            self?.links = filteredLinks
                        }
                    }
                DispatchQueue.main.async {
                    self?.updateUI()
                    self?.isBusy = false
                }
                //self?.processLinks()
            }
        }
    }
    
    func updateUI(){
        var rejected = 0
        var approved = 0
        var needManualReview = 0
        for state in reviewStates.values {
            if(state == IntermediateReviewState.Approve){
                approved+=1
            }else if(state == IntermediateReviewState.Reject){
                rejected+=1
            }else if(state == IntermediateReviewState.ManuallyReview){
                needManualReview+=1
            }
        }
        buttonTitle = ""
        if rejected > 0 || approved > 0  {
            if rejected > 0 {
                buttonTitle+="Reject \(rejected)"
            }
            
            if approved > 0 {
                if buttonTitle.count > 0 {
                    buttonTitle+=", "
                }
                buttonTitle+="Approve \(approved)"
            }
            return
        }
        if needManualReview > 0 {
            buttonTitle+="Review \(needManualReview)"
        }
    }
}
