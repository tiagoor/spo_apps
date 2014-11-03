# SharePoint Online (SPO) Apps

SPO (www.sharepoint.com) is offered as part and parcel with Office 365.

In the "small" endevour to use the REST API provided to access SPO, we have tried to leverage the benefit of consuming these resources from our Linux machines. We were successful to do so.

Documentation online is ample for .NET or Java snippets, however when it comes to cURL and bash scripting the documentation, we can confidently say that most will be at loss.

The code compiled in our apps has been sourced from examples used by .NET, PHP and Java. We had to reverse engineer the whole process in order to understand what is going on.

Other options one may have considered include the use of a snoop and reviewing the headers and body content using Wireshark. We avoided this as we wanted to follow the standards and fully comply with what MSDN "provides".

Anyway, we managed to pull our teeth together and come up with solutions for our requirements.

## SPO Upload App

https://github.com/SailonGroup/spo_apps/tree/master/spo_upload_app.

One of our requirements was to be able to upload files residing in an archive directory on a Linux machine to a Document Library in our SharePoint Online site.

In order to be able to authenticate and consume the SPO REST API, one first needs to send a login request to Azure Active Directory (AAD). If you have Office 365, you already have AAD in place (at no extra cost). Just access it at https://manage.windowsazure.com.

The login request with AAD will send a security token, where such token is then used to make a call on your SPO to retrieve the cookies. With the cookies retrieved, it is then safe to proceed to retrieve the Form Digest data which shall be used together with the cookies in all subsequent calls to the SPO REST API.

The "spo_upload_app.sh" script is very simple in terms of functionality. It will not create missing directors, so you need to make sure that the folder structure you have in the archive directory is also present in the Document Library you wish to upload the files to.

Files are uploaded to their respective folder and in the case where the file already exists, the "spo_upload_app.sh" script forces an overwrite.

The "spo_upload_app.sh" script is mainly based on the *find*, *cURL*, *sed*, and *awk* commands. These are generally readily available with any Linux or Unix distribution.

The "spo_upload_app.sh" script does not cache any data and only maintains a reference file in order to find files only newer than the date of the file thereof. This is done to avoid re-uploading of files.

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. cURL 7.19.7 (with support for *https*)

# Bash Scripting

Bash Scripting can be very plain, or very complex with functions and the parade it brings with it. These scripts have been generated with simplicity. However comments are welcome on improvements and we do hope Microsoft will offer more resources to consume their REST API for the Linux community.
