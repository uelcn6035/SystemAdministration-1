# WindowsAdministration

Active Directory User and Group Management Script
Abstract
Script Overview: This PowerShell script automates the management of Active Directory (AD) users and groups. It defines user details, creates groups if they do not exist, and manages user accounts by deleting existing ones, creating new ones, and adding them to the appropriate groups.
Password Management: Sets a secure password for all users by converting a plain text password into a secure string.
User Details: Contains user details, including first name, last name, username, and the group they belong to.
Group Management: Defines groups and their respective Organizational Units (OUs), and creates groups if they do not exist.
User Management: Deletes existing users, creates new users, and adds them to the appropriate groups, logging the success or failure of each operation.
Script Details
1. Define the Password
$password = ConvertTo-SecureString "Jeleel_Dev11" -AsPlainText -Force

This line sets a secure password for all users by converting the plain text password into a secure string.

