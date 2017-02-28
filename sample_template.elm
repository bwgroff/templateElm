import Tuple as T
import Html exposing (program, div, text, Html)

import SomeModule
import ThisModule
import ThatModule


main =
  Html.program
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update
  }


-- MODEL

type alias Model =
  { somemodule : SomeModule.Model
  , thismodule : ThisModule.Model
  , thatmodule : ThatModule.Model
  }


-- UPDATE

type Msg
  = SomeModuleMsg SomeModule.Msg
  | ThisModuleMsg ThisModule.Msg
  | ThatModuleMsg ThatModule.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
  
    SomeModuleMsg msg ->
      let
        componentUpdate = SomeModule.update msg model.somemodule
        newSubModel = T.first componentUpdate
        newCmd = Cmd.map (\m -> SomeModuleMsg m) (T.second componentUpdate)
      in
        (Model newSubModel model.thismodule model.thatmodule, newCmd)

    ThisModuleMsg msg ->
      let
        componentUpdate = ThisModule.update msg model.thismodule
        newSubModel = T.first componentUpdate
        newCmd = Cmd.map (\m -> ThisModuleMsg m) (T.second componentUpdate)
      in
        (Model model.somemodule newSubModel model.thatmodule, newCmd)

    ThatModuleMsg msg ->
      let
        componentUpdate = ThatModule.update msg model.thatmodule
        newSubModel = T.first componentUpdate
        newCmd = Cmd.map (\m -> ThatModuleMsg m) (T.second componentUpdate)
      in
        (Model model.somemodule model.thismodule newSubModel, newCmd)


init : (Model, Cmd Msg)
init =
  let
  
    somemoduleInit = SomeModule.init
    somemoduleModel = T.first somemoduleInit
    somemoduleCmd = Cmd.map (\m -> SomeModuleMsg m) (T.second somemoduleInit)
  
    thismoduleInit = ThisModule.init
    thismoduleModel = T.first thismoduleInit
    thismoduleCmd = Cmd.map (\m -> ThisModuleMsg m) (T.second thismoduleInit)
  
    thatmoduleInit = ThatModule.init
    thatmoduleModel = T.first thatmoduleInit
    thatmoduleCmd = Cmd.map (\m -> ThatModuleMsg m) (T.second thatmoduleInit)
  
  in
    ( Model  somemoduleModel  thismoduleModel  thatmoduleModel 
    , Cmd.batch
      [ somemoduleCmd
      , thismoduleCmd
      , thatmoduleCmd
      ]
    )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map (\m -> SomeModuleMsg m) (SomeModule.subscriptions model.somemodule)
    , Sub.map (\m -> ThisModuleMsg m) (ThisModule.subscriptions model.thismodule)
    , Sub.map (\m -> ThatModuleMsg m) (ThatModule.subscriptions model.thatmodule)
    ]

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Html.map (\m -> SomeModuleMsg m) (SomeModule.view model.somemodule)
    , Html.map (\m -> ThisModuleMsg m) (ThisModule.view model.thismodule)
    , Html.map (\m -> ThatModuleMsg m) (ThatModule.view model.thatmodule)
    ]
