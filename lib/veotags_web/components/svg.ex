defmodule VeotagsWeb.SVG do
  use Phoenix.Component

  attr :class, :string, default: "h-10"

  def veo(assigns) do
    ~H"""
    <svg
      version="1.1"
      id="svg1"
      viewBox="0 0 297.33334 150.66667"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:svg="http://www.w3.org/2000/svg"
      class={@class}
    >
      <g id="g1" inkscape:groupmode="layer" inkscape:label="1">
        <path
          id="path3"
          d="M 96.2031,831.797 382.207,336.629 668.211,831.797 Z"
          style="fill:none;stroke:currentColor;stroke-width:100;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
        <path
          id="path4"
          d="M 880.449,796.395 H 1387.48"
          style="fill:none;stroke:currentColor;stroke-width:100;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
        <path
          id="path5"
          d="M 880.449,568.57 H 1387.48"
          style="fill:none;stroke:currentColor;stroke-width:100;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
        <path
          id="path6"
          d="M 880.449,349.023 H 1387.48"
          style="fill:none;stroke:currentColor;stroke-width:100;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
        <path
          id="path7"
          d="m 2087.96,774.941 c 111.7,-111.687 111.7,-292.777 0,-404.468 -111.69,-111.692 -292.77,-111.692 -404.46,0 -111.7,111.691 -111.7,292.781 0,404.468 111.69,111.692 292.77,111.692 404.46,0"
          style="fill:none;stroke:currentColor;stroke-width:100;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
        <path
          id="path8"
          d="m 1921.09,608.063 c 19.52,-19.524 19.52,-51.184 0,-70.711 -19.53,-19.524 -51.19,-19.524 -70.71,0 -19.53,19.527 -19.53,51.187 0,70.711 19.52,19.527 51.18,19.527 70.71,0"
          style="fill:currentColor;fill-opacity:1;fill-rule:nonzero;stroke:none"
          transform="matrix(0.13333333,0,0,-0.13333333,0,150.66667)"
        />
      </g>
    </svg>
    """
  end
end
