![blob-checker](https://raw.githubusercontent.com/iam-theKid/ios-blob-checker/c3bccb309cc4e941ebe3c79c1ccc338650c5ae70/img/banner.png)
# ios-blob-checker
Check saved / dumped ios blobs (.shsh /.shsh2) against Release, Beta and OTA iOS Firmwares

# What does this do?
Checks if iOS blob files are valid and / or identifies which iOS version blob is valid for.

# How to use
1. Clone this repo with `git clone --recursive https://github.com/iam-theKid/ios-blob-checker.git && cd ios-blob-checker && chmod +x blobChecker.sh bins/*`
2. Run `./blobChecker.sh`
3. Drag and drop blob file into Terminal window;
4. Type device identifier (ex. iPhone12,3 or iPad7,6 etc)
5. Type iOS version to validate blob against. ** Note: Specific version is not required! See below: ***
  - **Major version (14, 15, 16)** - Check against all minor versions: ex. if 14 is selected, 14.01 - 14.8 will be checked, including beta and OTA versions.
  - **Partial version (ex. 15.3)** - Check against any version starting with 15.3: 15.3.1, 15.3 RC, 15.3 beta will be checked.
  - **Exact version (ex. 15.2 RC)**
![blob-checker](https://raw.githubusercontent.com/iam-theKid/ios-blob-checker/c3bccb309cc4e941ebe3c79c1ccc338650c5ae70/img/first.png)  
6. Blob file validation will start.   
7. Blob file will be copied and renamed when a valid version is confirmed.
  - ECID+DeviceIdentifier+iOSVersion+iOSBuildID.shsh
  - 00012345678_iPhone12,3_15.3.1_19D52.shsh
![blob-checker](https://raw.githubusercontent.com/iam-theKid/ios-blob-checker/c3bccb309cc4e941ebe3c79c1ccc338650c5ae70/img/second.png)

# binaries included
- img4tool (High Sierra or below and Catalina and above included)
- pzb
- jc

