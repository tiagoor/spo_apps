# SharePoint Online (SPO) Apps

SPO (www.sharepoint.com) is offered as part and parcel with Office 365.

In the "small" endevour to use the REST API SPO provides, we tried to leverage the benefit of consuming the resources from our Linux machines.

Documentation online is ample for .NET or JavaScript snippets, however when it comes to cURL and Bash Scripting the documentation is very poor.

Anyway, we managed to pull our teeth together and come up with solutions for our requirements.

## SPO Upload App

https://github.com/SailonGroup/spo_apps/tree/master/spo_upload_app.

One of our requirements was to be able to upload files residing in an archive directory to a Document Library in our SharePoint Online site.

The "spo_upload_app.sh" script is very simple in terms of functionality. It will not create missing directors, so you need to make sure that the folder structure you have in the archive directory is also present in the Document Library you wish to upload.

Files are uploaded to their respective folder and in the case where the file already exists, the "spo_upload_app.sh" script forces an overwrite.

The "spo_upload_app.sh" script is mainly based on the *find*, *cURL*, *sed*, and *awk* commands. These are generally readily available with any Linux or Unix distribution.

The "spo_upload_app.sh" script does not cache any data and only maintains a reference file in order to find files only new than the date of the file thereof. This is done to avoid re-uploading of files.

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. cURL 7.19.7 (with support for *https*)

# Bash Scripting

Bash Scripting can be very plain, or very complex with functions and the parade it brings with it. These scripts have been generated with simplicity. However comments are welcome on improvements and we do hope Microsoft will offer more resources to consume their REST API for the Linux community.
