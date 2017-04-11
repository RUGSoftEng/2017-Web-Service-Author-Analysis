# Author Analysis Frontend 


## Installing dependencies 

Assuming a recent version of `npm` (the same tool used for the backend dependencies). 

```sh
npm install -g elm # the elm compiler. You can also download an installer from https://guide.elm-lang.org/install.html
npm install -g elm-test # optional: program that runs tests on our code base

elm-package install # downloads all needed elm packages
``` 

The elm guide contains a section on [configuring your editor](https://guide.elm-lang.org/install.html). If you are unsure what editor to use, [Atom](https://atom.io/) is probably the best choice (it has the best tooling), although [Sublime Text](https://www.sublimetext.com/) will do fine too. 

### elm-format

If you want to modify the elm code, please install and use [elm-format](https://github.com/avh4/elm-format#installation-). 

On Nix systems, the elm-format executable has to be somewhere on your path. You can either move or symlink it to `usr/bin`

On windows systems, the elm-format.exe executable has to be in your PATH. The easiest way is to find out where elm is installed with `where elm-make` and 
copy elm-format.exe into the same folder. 

Finally, you need to configure your editor to find and use elm-format. 

## Running the app 

### with the nodejs server (recommended)

Make sure the webserver is running (see `backend/README.md`), then browse to [localhost:8080](http://localhost:8080/) to view
the application. 

At this time, the frontend does not reload (i.e. automatically compile and refresh the page) when an elm file changes. You have to manually 
stop the server and start it again. 

## Crash Course Elm: Architecture overview 

An elm app consists of 2 types and 3 functions

* `Model` contains all the data (state) of the application.
    ```elm
    type alias Model = { prediction : Bool, confidence : Float }
    ```

* Msg (for "message") describes all the actions our program can perform.

    ```elm
    type Msg 
        = ToggleFeature Feature             -- turns a particular feature on or of
        | ToggleUploadMethod UploadMethod   -- switches between FileUpload and PasteText
    ```

* `update : Msg -> Model -> ( Model, Cmd Msg )` advances the state of the model based on some message. 
    `Cmd Msg` (cmd for "command") means some effect (like sending an http request) that will produce a `Msg` when it is finished. This `Msg` is automatically given to `update` and so the update cycle continues.
 
    ```elm
    update : Msg -> Model -> ( Model, Cmd Msg ) 
    update message model = 
        case message of 
            ToggleFeature feature -> 
                ...  

            ToggleUploadMethod method -> 
                ...
    ```

* `view : Model -> Html Msg` converts the model to html.
    the `Msg` in `Html Msg` means that when some event is triggered in the html, a `Msg` will be sent to `update`. 

    ```elm
    view : Model -> Html Msg 
    view model = 
        div [] 
            [ text ("We predict" ++ toString model.prediction 
            					 ++ " with " ++ (toString model.confidence) ++ "% confidence")
            , button [ onClick ToggleUploadMethod ] [ text "Toggle the upload method" ] 
            ] 
    ```

* `subscriptions` handles input from the outside, for example the time or mouse movement. In our application we use subscriptions 
for some Bootstrap components that have animations.  

### Resources 

* [The Elm Guide](https://guide.elm-lang.org/) an introduction to all the concepts of the language. 
* [The Elm Slack](http://elmlang.herokuapp.com/) make a slack account and pop in there, everyone is really nice! This is the location to ask questions and get a response quickly. 
In particular the #beginners and #general channels are interesting. 
* [Elm Bootstrap](http://elm-bootstrap.info/) the UI library we use
* [package.elm-lang.org](http://package.elm-lang.org/) documentation for elm packages (and the language in general).
