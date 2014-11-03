# SharePoint Online (SPO) Apps

SPO (www.sharepoint.com) is offered as part and parcel with Office 365.

In the "small" endevour to use the REST API provided to access SPO, we have tried to leverage the benefit of consuming these resources from our Linux machines. We were successful to do so.

Documentation online is ample for .NET or Java snippets, however when it comes to cURL and bash scripting the documentation, we can confidently say that most will be at loss.

The code compiled in our apps has been sourced from examples used by .NET, PHP and Java. We had to reverse engineer the whole process in order to understand what is going on.

Other options one may have considered include the use of a snoop and reviewing the headers and body content using Wireshark. We avoided this as we wanted to follow the standards and fully comply with what MSDN "provides".

Anyway, we managed to pull our teeth together and come up with solutions for our requirements.

## SPO Upload App

https://github.com/SailonGroup/spo_apps/tree/master/spo_upload_app.

One of our requirements was to be able to upload files residing in a local directory on a Linux machine to a Document Library in our SharePoint Online site.

In order to be able to authenticate and consume the SPO REST API, one first needs to send a login request to Azure Active Directory (AAD). If you have Office 365, you already have AAD in place (at no extra cost). Just access it at https://manage.windowsazure.com.

The sequence of authentication is as follows:

1. **(Tx)** HTTPS POST request to AAD with body content containing SAML, including **_username_**, **_password_** and **_endpoint_**.
2. **(Rx)** HTTPS POST response from AAD with body content containing **_Security Token_**.
3. **_(Pr)_** Extraction of the Security Token into a variable.
4. **(Tx)** HTTPS GET request to SPO with header containing the Security Token.
5. **(Rx)** HTTPS GET response from SPO with **_Cookies_**.
6. **(Tx)** HTTPS GET request to SPO with header containing Cookies.
7. **(Rx)** HTTPS GET response from SPO with body content containing the **_Form Digest_**.
8. **_(Pr)_** Extraction of the Form Digest into a variable.

**Note:** Tx = Transmit, Rx = Recieve, Pr = Process/Manipulate.

Once you have both the Cookies and the Form Digest, you can proceed to perform any call to consume any of the services exposed by the REST API for SPO.

The "spo_upload_app.sh" script is very simple in terms of functionality. It will not create missing directors, so you need to make sure that the folder structure you have in the local directory is also present in the Document Library you wish to upload the files to.

Files are uploaded to their respective folder and in the case where the file already exists, the "spo_upload_app.sh" script forces an overwrite.

The "spo_upload_app.sh" script is mainly based on the _find_, _cURL_, _sed_, and _awk_ commands. These are generally readily available with any Linux or Unix distribution.

The "spo_upload_app.sh" script does not cache any data and only maintains a reference file in order to find files only newer than the date of the file thereof. This is done to avoid re-uploading of files.

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. cURL 7.19.7 (with support for _https_)

# Bash Scripting

Bash Scripting can be very plain, or very complex with functions and the parade it brings with it. These scripts have been generated with simplicity. However comments are welcome on improvements and we do hope Microsoft will offer more resources to consume their REST API for the Linux community.
