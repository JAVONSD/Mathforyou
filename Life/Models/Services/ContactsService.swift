//
//  ContactsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI
import DateToolsSwift

class ContactsService: NSObject {

    static let shared = ContactsService()

    var contactSaveCompletion: ((Bool) -> Void)?

    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])

        var results: [CNContact] = []

        do {
            try contactStore.enumerateContacts(with: request) { (contact, _) -> Void in
                results.append(contact)
            }
        } catch {
            print("Error fetching results for container")
        }

        return results
    }()

    // MARK: - Methods

    public func isContactExists(for employee: Employee) -> Bool {
        return contacts.contains(where: { (contact) -> Bool in
            for phone in contact.phoneNumbers {
                if phone.value.stringValue == employee.workPhoneNumber
                    || phone.value.stringValue == employee.mobilePhoneNumber {
                    return true
                }
            }
            return false
        })
    }

    public func save(employee: Employee, presentIn navController: UINavigationController) {
        let store = CNContactStore()

        let contact = CNMutableContact()
        contact.givenName = employee.fullname
        contact.jobTitle = employee.jobPosition
        contact.organizationName = employee.company
        contact.departmentName = employee.departmentName

        if employee.birthDate.date.isEarlier(than: Date()) {
            var dateComponents = DateComponents()
            dateComponents.year = employee.birthDate.date.year
            dateComponents.month = employee.birthDate.date.month
            dateComponents.day = employee.birthDate.date.day
            contact.birthday = dateComponents
        }

        var phoneNumbers = [CNLabeledValue<CNPhoneNumber>]()
        if !employee.mobilePhoneNumber.isEmpty {
            let mobilePhone = CNLabeledValue(
                label: CNLabelPhoneNumberMobile,
                value: CNPhoneNumber(stringValue: employee.mobilePhoneNumber)
            )
            phoneNumbers.append(mobilePhone)
        }
        if !employee.workPhoneNumber.isEmpty {
            let workPhone = CNLabeledValue(
                label: CNLabelWork,
                value: CNPhoneNumber(stringValue: employee.workPhoneNumber)
            )
            phoneNumbers.append(workPhone)
        }
        contact.phoneNumbers = phoneNumbers

        var emailAddresses = [CNLabeledValue<NSString>]()
        if !employee.email.isEmpty {
            let emailAddress = CNLabeledValue(
                label: CNLabelWork,
                value: NSString(string: employee.email)
            )
            emailAddresses.append(emailAddress)
        }
        contact.emailAddresses = emailAddresses

        let controller = CNContactViewController(forUnknownContact: contact)
        controller.contactStore = store
        controller.delegate = self
        navController.pushViewController(controller, animated: true)
    }

}

extension ContactsService: CNContactViewControllerDelegate {
    func contactViewController(
        _ viewController: CNContactViewController,
        didCompleteWith contact: CNContact?) {
        if let contact = contact {
            contacts.append(contact)
        }

        if let contactSaveCompletion = contactSaveCompletion {
            contactSaveCompletion(contact != nil)
        }

        viewController.navigationController?.popToRootViewController(animated: true)
    }
}
