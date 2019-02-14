# README #

## About

The Sitecore Publish Queue Detail report is a single-file, drop-in utility for viewing detailed info from the Sitecore Publish Queue. This is handy for verifying what will be published during the next Incremental Publish or for troubleshooting publishing issues.

* Current version: 1.0.0
* About & Download: [Sitecore Publish Queue Detail (GitHub)](https://github.com/bmbruno/SitecoreSpark.Admin.PublishQueueDetail)

## Features

Publish Queue information is only accessible via the database (`dbo.PublishQueue` table) or via the Sitecore API (`Sitecore.Publishing.PublishManager` class). This utility utilizes the API to generate a report of all items in the Publish Queue, and includes the following information for each item:

* ID
* Name
* Language
* Publish Action
* Source Database
* Target Database

There may be a discrepency in the publish queue totals between the _Publish Queue Stats_ page and this report. This is because Sitecore uses two different methods for loading publish queue information (you need to go deep into the Sitecore SQL DataProvider classes in Sitecore.Kernel.dll to digest this). In short, this report uses the same pipeline processor methods that Incremental Publishing uses.

## Requirements

* Sitecore 8.0 or greater

## Getting Started

#### 1. Installation ####

Copy the `PublishQueueDetail.aspx` file and place it inside the Sitecore admin directory (`<your_webroot>/sitecore/admin`). You **can** place it anywhere in the webroot, but this information should probably only be accessed by admin-level users.

#### 2. Configuration ####

The file is a self-contained ASPX page, with all backend logic inline with a `<script>` tag. Near the top of the C# script code, you can update the `dbMaster` and `dbWeb` values to match your master and web databases, respectively.

## Contact the Author

For questions / comments / issues, contact me:
* Twitter: [@BrandonMBruno](https://www.twitter.com/BrandonMBruno) or [@SitecoreSpark](https://www.twitter.com/SitecoreSpark)
* Email: bmbruno [at] gmail [dot] com
 
## License

MIT License. See accompanying "License.txt" file.
