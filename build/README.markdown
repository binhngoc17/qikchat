An QikAChat is sample application design and implemented for self assessment in Objective-C for the Mac / iOS.

# HOW TO MAKE IPA FILE FROM xcode xc archive project

1. Copy provisioning profile to build folder
2. Copy QikAChat.xcarchive archive project to build folder
3. Open command prompt ie
4. Go to build folder
5. Run to below command i.e 
 xcodebuild -exportArchive -archivePath QikAChat.xcarchive -exportPath QikAChat -exportFormat ipa -exportProvisioningProfile "Pintel_dev"


# end of file
