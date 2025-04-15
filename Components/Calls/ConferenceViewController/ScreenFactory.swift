//
//  ModuleFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

final class ScreenFactory:
    AuthModuleFactory,
    DialogsModuleFactory,
    ChatModuleFactory,
    SharingModuleFactory,
    ConferenceModuleFactory {
    func makeConferenceOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
        return ConferenceViewController(conferenceSettings: conferenceSettings)
    }
    
    func makeChatOutput() -> ChatView {
        return ChatViewController.controllerFromStoryboard(.chat) as! ChatView
    }
//    func makeDialogsOutput() -> DialogsView {
//        return DialogsViewController.controllerFromStoryboard(.dialogs)
//    }
    
    func makeStreamInitiatorOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
       return StreamInitiatorViewController(conferenceSettings: conferenceSettings)
    }
    
    func makeStreamParticipantOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
        return StreamParticipantViewController(conferenceSettings: conferenceSettings)
    }
    
  
    
}
