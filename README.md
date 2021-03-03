[![Build](https://github.com/Project-Pipeline/Pipeline-backend/workflows/CI/badge.svg)](https://github.com/Project-Pipeline/Pipeline-backend/actions)

# Pipeline Backend

The backend code for Project Pipeline, coded with [Vapor](https://vapor.codes) 4.

## Notes
* For the app to work you must add a  `config.json`  (ignored by git) containing the following contents to the project's directory.
```json
    {
        "googleClientID": "your client id",
        "googleClientSecret": "your client secret",
        "googleCallbackURL": "your callback url",
        "mongoURL": "your mongo url in base64 encoded form",
        "cloudinaryAPISecret": "cloudinary API secret",
        "unrestrictedCORS": "true/false"
    }
```
* Run `source setup.sh` to setup the essential environmental variables for this project.
    

