"""
Creates simplest Elm app containing individual listed components.
If you want the components to interact, just modify `update`.
As far as making it look nice, you're on your own.
"""

from jinja2 import Template, environment


def makeItSo(modules, template):
    t = Template(template)
    return t.render(modules=modules)


TEMPLATE = """import Tuple as T
import Html exposing (program, div, text, Html)
{% for module in modules %}import {{module}}
{% endfor %}
main =
  Html.program
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update
  }
-- MODEL
type alias Model =
  { {{modules[0] | lower}} : {{modules[0]}}.Model{% for module in modules[1:] %}
  , {{module | lower}} : {{module}}.Model{% endfor %}
  }
-- UPDATE
type Msg
  = {{modules[0]}}Msg {{modules[0]}}.Msg{% for module in modules[1:]%}
  | {{module}}Msg {{module}}.Msg{% endfor %}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
  {% for module in modules %}
    {{module}}Msg msg ->
      let
        componentUpdate = {{module}}.update msg model.{{module | lower}}
        newSubModel = T.first componentUpdate
        newCmd = Cmd.map {{module}}Msg (T.second componentUpdate)
      in
        ({ model | {{module | lower}} = newSubModel }, newCmdModel )
{%endfor%}
init : (Model, Cmd Msg)
init =
  let
  {% for module in modules %}
    {{module | lower}}Init = {{module}}.init
    {{module | lower}}Model = T.first {{module | lower}}Init
    {{module | lower}}Cmd = Cmd.map {{module}}Msg (T.second {{module | lower}}Init)
  {% endfor %}
  in
    ( Model {% for module in modules %} {{module | lower}}Model {% endfor %}
    , Cmd.batch
      [ {{modules[0] | lower}}Cmd{% for module in modules[1:] %}
      , {{module | lower}}Cmd{% endfor %}
      ]
    )
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map {{modules[0]}}Msg ({{modules[0]}}.subscriptions model.{{modules[0] | lower}}){% for module in modules[1:] %}
    , Sub.map {{module}}Msg ({{module}}.subscriptions model.{{module | lower}}){% endfor %}
    ]
-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ Html.map {{modules[0]}}Msg ({{modules[0]}}.view model.{{modules[0] | lower}}){% for module in modules[1:] %}
    , Html.map {{module}}Msg ({{module}}.view model.{{module | lower}}){% endfor %}
    ]
"""

if __name__ == "__main__":
    import sys
    modules = sys.argv[1:]
    assert len(modules) == len(set(modules)), "Modules list contains repetition"
    print(makeItSo(modules, TEMPLATE))
