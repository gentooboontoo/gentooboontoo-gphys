require "numru/gphys"
require "numru/dcl"
require "numru/misc"
require "date"
require "numru/dclext_datetime_ax"

############################################################

=begin
=module NumRu::GGraph and others in ggraph.rb

==Index
* ((<module NumRu::GGraph>))
  * ((<margin_info>))
    Sets the strings to appear in the bottom margin.
  * ((<title>))
    Shows title by (({DCL.uxmttl('t',string,0.0)})).
    Graphic methods such as ((<contour>)) calls this by default.
  * ((<annotate>))
    Show texts on the right margin of the viewport.
    Graphic methods such as ((<contour>)) calls this by default.
  * ((<fig>))
    Define a figure by setting viewport, window, and coordinate transform
    id (itr) from two 1D VArrays (({xax})) and (({yax})).
  * ((<set_fig>))
    Change the default option values for ((<fig>)).
  * ((<next_fig>))
    Set the option values effective only in the next call of ((<fig>))
    (cleared then).
  * ((<axes>))
    Draw axes using (by default) info in (({xax})) and (({yax})) if non-nil.
  * ((<set_axes>))
    Change the default option values for ((<axes>)).
  * ((<next_axes>))
    Set the option values effective only in the next call of ((<axes>))
    (cleared then).
  * ((<map_trn?>))
    Returns whether the current coordinate transformation is a map projection.
  * ((<map>))
    (For map projection) Draws map grid and/or lim and/or coast lines etc.
  * ((<set_map>))
    Change the default option values for ((<map>)).
  * ((<next_map>))
    Set the option values effective only in the next call of ((<map>))
  * ((<line>))
    Plot a poly-line by selecting the first dimension (with GPhys#first1D)
    if (({gphys})) is more than 2D.
  * ((<mark>))
    Similar to ((<line>)) but plots marks instead of drawing a poly-line.
  * ((<contour>))
    Contour plot by selecting the first 2 dimensions (with GPhys#first2D)
    if (({gphys})) is more than 3D.
  * ((<set_contour>))
    Set options for contour in general.
  * ((<next_contour>))
    Set options for contour in general, which is applied only to the next call.
  * ((<set_contour_levels>))
    Set contour levels for ((<contour>)) explicitly by values with the option (({levels})).
  * ((<clear_contour_levels>))
    Clear contour levels set by ((<set_contour_levels>)).
  * ((<set_linear_contour_options>))
    Change the default option values regarding linear contour level
    setting in ((<contour>)).
  * ((<next_linear_contour_options>))
    Similar to ((<set_linear_contour_options>)) but the setting
    is effective only for the next call of ((<contour>)).
  * ((<tone>))
    Color tone or shading by selecting the first 2 dimensions
    (with GPhys#first2D) if (({gphys})) is more than 3D.
  * ((<color_bar >)) Color bar
  * ((<set_tone_levels>))
    Set tone levels for ((<tone>)) explicitly by values.
  * ((<set_tone>))
    Set options for tone in general.
  * ((<next_tone>))
    Set options for tone in general, which is applied only to the next call.
  * ((<clear_tone_levels>))
    Clear tone levels set by ((<set_tone_levels>)).
  * ((<set_linear_tone_options>))
    Change the default option values regarding linear tone level
    setting in ((<tone>)).
  * ((<next_linear_tone_options>))
    Similar to ((<set_linear_tone_options>)) but the setting
    is effective only for the next call of ((<tone>)).
  * ((<vector>)) 2-D vector plot using DCL_Ext::((<flow_vect>))

* ((<module NumRu::DCLExt>))
  * ((<gl_set_params>))
    Calls (({DCL.glpset})) multiple times (for each key and val of (({hash}))).
  * ((<sg_set_params>))
    Calls (({DCL.sgpset})) multiple times (for each key and val of (({hash}))).
  * ((<sl_set_params>))
    Calls (({DCL.slpset})) multiple times (for each key and val of (({hash}))).
  * ((<sw_set_params>))
    Calls (({DCL.swpset})) multiple times (for each key and val of (({hash}))).
  * ((<uz_set_params>))
    Calls (({DCL.uzpset})) multiple times (for each key and val of (({hash}))).
  * ((<ul_set_params>))
    Calls (({DCL.ulpset})) multiple times (for each key and val of (({hash}))).
  * ((<uc_set_params>))
    Calls (({DCL.ucpset})) multiple times (for each key and val of (({hash}))).
  * ((<uu_set_params>))
    Calls (({DCL.uupset})) multiple times (for each key and val of (({hash}))).
  * ((<us_set_params>))
    Calls (({DCL.uspset})) multiple times (for each key and val of (({hash}))).
  * ((<ud_set_params>))
    Calls (({DCL.udpset})) multiple times (for each key and val of (({hash}))).
  * ((<ud_set_linear_levs>))
    Set contour levels with a constant interval
  * ((<ud_set_contour>))
    Set contours of at specified levels.
  * ((<ud_add_contour>))
    Same as ((<ud_set_contour>)), but does not clear the contour levels that have
    been set.
  * ((<ue_set_params>))
    Calls (({DCL.uepset})) multiple times (for each key and val of (({hash}))).
  * ((<ue_set_linear_levs>))
    Set tone levels with a constant interval
  * ((<ue_set_tone>))
    Set tone levels and patterns.
  * ((<ue_add_tone>))
    Same as ((<ue_set_tone>)), but does not clear the tone levels that have
    been set.
  * ((<ug_set_params>))
    Calls (({DCL.ugpset})) multiple times (for each key and val of (({hash}))).
    See ((<gl_set_params>)) for usage.
  * ((<um_set_params>))
    Calls (({DCL.umpset})) multiple times (for each key and val of (({hash}))).

  * ((<set_unit_vect_options>))
  * ((<next_unit_vect_options>))
  * ((<unit_vect>)) Show the "unit vector", which indicate the vector scaling.
  * ((<flow_vect>)) 2D Vector plot. Unlike (({DCL::ugvect})), scaling are made in term of the physical (or "U") coordinate.
  * ((<flow_itr5>)) 2D Vector plot on the 2-dim polar coodinate.
  * ((<color_bar>)) Color Bar

=module NumRu::GGraph

A graphic library for GPhys using RubyDCL.

This module uses GPhys but is not a part of it.
More specifically, even though this module is included in
the GPhys distribution, the class NumRu::GPhys knows nothing about it,
and GGraph accesses GPhys only though public methods.
So GGraph is not an insider, and you can make another graphic
library if you like.

==Module Functions

---margin_info(program=nil, data_source=nil, char_height=nil, date=nil, xl=0.0, xr=0.0, yb=nil, yt=0.0)

    Sets the strings to appear in the bottom margin.

    This method sets margin widths as DCL.slmgn(xl, xr, yb, yt),
    and sets the 1st and 2nd margin strings as (({program}))
    and (({data})).

    ARGUMENTS
    * program (String or nil) : String to be put on the left side in
      the bottom margin. This is meant to represent the name of the
      execution program. Therefore, if it is nil, the full path of
      $0 is used.

    * data_source (String or nil) : String to be put on the right side in
      the bottom margin. This is meant to represent the data file name or the
      directory in which the data are situated.
      If nil, the full path of the current directory is used
      (but nothing is shown if it is equal to the directory of the program).

    * date (true, false, nil) : whether to put todays date --
      true: always, nil: if program.length is short enough, false: never

    * char_height (Float or nil) : height of the string to appear
      in the V coordinate. If nil, internally defined.

    * xl, xr, yb, yl (Float --- nil is available for yb) : margin
      size in the V coordinate. The margin is set as
      DCL.slmgn(xl, xr, yb, yt). If (({yb})) is nil, it is determined
      internally as (({2.0 * char_height})).

---title(string)
    Shows title by (({DCL.uxmttl('t',string,0.0)})).
    Graphic methods such as ((<contour>)) calls this by default.

    RETURN VALUE
    * nil

---annotate(str_ary)
    Show texts on the right margin of the viewport.
    Graphic methods such as ((<contour>)) calls this by default.

    ARGUMENTS
    * str_ary (Array of String) :

    RETURN VALUE
    * nil

---fig(xax=nil, yax=nil, options=nil)
    Define a figure by setting viewport, window, and coordinate transform
    id (itr) from two 1D VArrays (({xax})) and (({yax})) (which are
    not needed if a map projection is specified with the optional
    parameter 'itr').

    (({DCL.grfrm})) or (({DCL.grfig})) is called depending options provided.

    ARGUMENTS
    * xax (VArray): (Used only if not map projection)
      A VArray representing the x (horizontal) coordinate
      of the figure.
      The x range of the window (UXMIN & UYMAX in DCL) are determined
      with the max and min of (({xax.val})). By default,
      the min and max values are assigned to the left and right
      boundaries, respectively, but it is reversed if (({xax})) has
      a 'positive' attribute and its value is 'down' etc (see (({options}))).
    * yax (VArray): (Used only if not map projection)
      Similar to (({xax})) but for the y (vertical) coordinate
      of the figure.
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "new_frame"   true    # whether to define a new frame by DCL.grfrm
                             # (otherwise, DCL.grfig is called)
       "no_new_fig"  false   # If true, neither DCL.grfrm nor DCL.grfig
                             # is called (overrides new_frame) -- Then, you need
                             # to call one of them in advance. Convenient to set
                             # DCL parameters that are reset by grfrm or grfig.
       "itr"         1       # coordinate transformation number
       "viewport"    [0.2, 0.8, 0.2, 0.8]    # [vxmin, vxmax, vymin, vymax]
       "eqdistvpt"   false   # modify viewport to equidistant for x and y
                             # (only for itr=1--4)
       "window"      nil     # (for itr<10,>50) [uxmin, uxmax, uymin, uymax],
                             # each element allowed nil (only for itr<5,>50)
       "xreverse"    "positive:down,units:hPa"       # (for itr<10,>50) Assign
                             # max value to UXMIN and min value to UXMAX if
                             # condition is satisfied (nil:never, true:always,
                             # String: when an attibute has the value specified
                             # ("key:value,key:value,..")
       "yreverse"    "positive:down,units:hPa"       # (for itr<10,>50) Assign
                             # max value to UYMIN and min value to UYMAX if
                             # condition is satisfied (nil:never, true:always,
                             # String: when an attibute has the value specified
                             # ("key:value,key:value,..")
       "round0"      false   # expand window range to good numbers (effective
                             # only to internal window settings)
       "round1"      false   # expand window range to good numbers (effective
                             # even when "window" is explicitly specified)
       "similar"     nil     # (for rectangular curvilinear coordinate only)
                             # 3-element float array for similar transformation
                             # in a rectangular curvilinear coordinate, which
                             # is fed in DCL:grssim:[simfac,vxoff,vyoff],where
                             # simfac and [vxoff,vyoff] represent scaling
                             # factor and origin shift, respectively.
       "map_axis"    nil     # (for all map projections) 3-element float
                             # array to be fed in DCL::umscnt: [uxc, uxy, rot],
                             # where [uxc, uyc] represents the tangential point
                             # (or the pole at top side for cylindrical
                             # projections), and rot represents the rotation
                             # angle. If nil, internally determined. (units:
                             # degrees)
       "map_radius"  nil     # (for itr>=20: conical/azimuhal map
                             # projections) raidus around the tangential point.
                             # (units: degrees)
       "map_fit"     nil     # (Only for itr=10(cylindrical) and 11 (Mercator))
                             # true: fit the plot to the data window
                             # (overrides map_window and map_axis); false: do
                             # not fit (then map_window and map_axis are used);
                             # nil: true if itr==10, false if itr==11
       "map_window"  [-180, 180, -75, 75]    # (for itr<20: cylindrical
                             # map projections) lon-lat window [lon_min,
                             # lon_max, lat_min, lat_max ] to draw the map
                             # (units: degres)
       "help"        false   # show help message if true

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * those from NumRu::DCL if any / TypeError if any
    * options has a key that does not match any of the option names.
    * options has a key that is ambiguous

---set_fig(options)
    Change the default option values for ((<fig>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<fig>)).

    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

    POSSIBLE EXCEPTIONS
    * see ((<fig>)).

---next_fig(options)
    Set the option values effective only in the next call of ((<fig>))
    (cleared then).

    These value are overwritten if specified explicitly in the next
    call of ((<fig>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<fig>)).

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * see ((<fig>)).

---axes(xax=nil, yax=nil, options=nil)
    Draw axes using (by default) info in (({xax})) and (({yax})) if non-nil.

    ARGUMENTS
    * xax (nil or VArray): if non-nil, attributes 'long_name' and 'units'
      are read to define (({xtitle})) and (({xunits})) (see below).
      These are overwritten by explicitly specifying (({xtitle})) and
      (({xunits})).
    * yax (nil or VArray): if non-nil, attributes 'long_name' and 'units'
      are read to define (({ytitle})) and (({yunits})) (see below).
      These are overwritten by explicitly specifying (({ytitle})) and
      (({yunits})).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "xside"       "tb"    # Where to draw xaxes (combination of t, b and u)
       "yside"       "lr"    # Where to draw yaxes (combination of l, r and u)
       "xtitle"      nil     # Title of x axis (if nil, internally determined)
       "ytitle"      nil     # Title of y axis (if nil, internally determined)
       "xunits"      nil     # Units of x axis (if nil, internally determined)
       "yunits"      nil     # Units of y axis (if nil, internally determined)
       "xtickint"    nil     # Interval of x axis tickmark
                             #                 (if nil, internally determined)
       "ytickint"    nil     # Interval of y axis tickmark
                             #                 (if nil, internally determined)
       "xlabelint"   nil     # Interval of x axis label
                             #                 (if nil, internally determined)
       "ylabelint"   nil     # Interval of y axis label
                             #                 (if nil, internally determined)
       "xmaplabel"   false   # If "lon"("lat"), use
                             # DCLExt::lon_ax(DCLExt::lat_ax) to draw xaxes;
                             # otherwise, DCL::usxaxs is used.
       "ymaplabel"   false   # If "lon"("lat"), use
                             # DCLExt::lon_ax(DCLExt::lat_ax) to draw yaxes;
                             # otherwise, DCL::usyaxs is used.
       "time_ax"     nil     # Type of calendar-type time axis: nil (=> auto
                             # slection), false (do not use the time axis even
                             # if the units of the axis is a time one with since
                             # field), "h" (=> like nil, but always use the
                             # hour-resolving datetime_ax method in
                             # dclext_datetime_ax.rb), or "ymd" (=> like "h" but
                             # for y-m-d type using DCL.uc[xy]acl)
       "help"        false   # show help message if true

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * those from NumRu::DCL if any / TypeError if any
    * options has a key that does not match any of the option names.
    * options has a key that is ambiguous

---set_axes(options)
    Change the default option values for ((<axes>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<axes>)).

    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

    POSSIBLE EXCEPTIONS
    * see ((<axes>)).

---next_axes(options)
    Set the option values effective only in the next call of ((<axes>))
    (cleared then).

    These value are overwritten if specified explicitly in the next
    call of ((<axes>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<axes>)).

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * see ((<axes>)).

---sim_trn?
    Returns whether the current coordinate transformation is a rectangular
    curvelinear coordinate. A coordinate transformation must have been
    established with ((<fig>)) or (({DCL::grstrf})).
    Mainly for internal usage, but a user can use it too.

    RETURN VALUE
    * true or false

---polar_coordinate_boundaries(xax=nil,yax=nil)
    Draw boundaries in a polar coordinate.

    ARGUMENTS
    * xax (VArray): Grid points of the radial coordinate.
    * yax (VArray): Grid points of the azimuthal coordinate.

    RETURN VALUE
    * nil

---map_trn?
    Returns whether the current coordinate transformation is a map projection.

    A coordinate transformation must have been established
    with ((<fig>)) or (({DCL::grstrf})).
    Mainly for internal usage, but a user can use it too.

    RETURN VALUE
    * true or false

---map(options=nil)
    (For map projection) Draws map grid and/or lim and/or coast lines etc.

    ARGUMENTS
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
        option name   default value   # description:
        "lim"         true    # draw map lim (t or f)
        "grid"        true    # draw map grid (t or f)
        "vpt_boundary" false  # draw viewport boundaries (f, t or
                              # 1,2,3.., representing the line width)
        "wwd_boundary" false  # draw worksation window boundaries (f, t
                              # or 1,2,3.., representing the line width)
        "fill"        false   # fill the map if coast_world or coast_japan is
                              # true (t or f)
        "coast_world" false   # draw world coast lines (t or f)
        "border_world" false  # draw nation borders (t or f)
        "plate_world" false   # draw plate boundaries (t or f)
        "state_usa"   false   # draw state boundaries of US (t or f)
        "coast_japan" false   # draw japanese coast lines (t or f)
        "pref_japan"  false   # draw japanese prefecture boundaries (t or
                              # f)
        "dgridmj"     nil     # the interval between the major lines of
                              # latitudes and longitudes. If nil, internally
                              # determined. (units: degrees) (this is a UMPACK
                              # parameter, which is nullified when uminit or
                              # grfrm is called)
        "dgridmn"     nil     # the interval between the minor lines of
                              # latitudes and longitudes. If nil, internally
                              # determined. (units: degrees) (this is a UMPACK
                              # parameter, which is nullified when uminit or
                              # grfrm is called)
        "help"        false   # show help message if true

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * if called when the coordinate tansformation has not been established or
      the transformation is not a map projection.
    * those from NumRu::DCL if any / TypeError if any
    * options has a key that does not match any of the option names.
    * options has a key that is ambiguous

---set_map(options)
    Change the default option values for ((<map>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<map>)).

    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

    POSSIBLE EXCEPTIONS
    * see ((<map>)).

---next_map(options)
    Set the option values effective only in the next call of ((<map>))
    (cleared then).

    These value are overwritten if specified explicitly in the next
    call of ((<map>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<map>)).

    RETURN VALUE
    * nil

    POSSIBLE EXCEPTIONS
    * see ((<map>)).

---line(gphys, newframe=true, options=nil)
    Plot a poly-line by selecting the first dimension (with GPhys#first1D)
    if (({gphys})) is more than 2D.

    ARGUMENTS
    * gphys (GPhys) : a GPhys whose data is plotted.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "title"       nil     # Title of the figure(if nil, internally
                             # determined)
       "annotate"    true    # if false, do not put texts on the right
                             # margin even when newframe==true
       "exchange"    false   # whether to exchange x and y axes
       "index"       1       # line/mark index
       "type"        1       # line type
       "label"       nil     # if a String is given, it is shown as the label
       "max"         nil     # maximum data value
       "min"         nil     # minimum data value
       "legend"      nil     # legend to annotate the line type and index. nil
                             # (defalut -- do not show); a String as the legend;
                             # true to use the name of the GPhys as the legend
       "legend_vx"   nil     # (effective if legend) viewport x values of
                             # the lhs of the legend line (positive float); or
                             # nil for automatic settting (shown to the right of
                             # vpt); or move it to the left relatively (negtive
                             # float)
       "legend_dx"   nil     # (effective if legend) length of the legend
                             # line
       "legend_vy"   nil     # (effective if legend) viewport y value of the
                             # legend (Float; or nil for automatic settting)
       "legend_size" nil     # (effective if legend) character size of the
                             # legend
       "map_axes"    false   # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "help"        false   # show help message if true

    RETURN VALUE
    * nil

---mark(gphys, newframe=true, options=nil)
    Similar to ((<line>)) but plots marks instead of drawing a poly-line.

    ARGUMENTS
    * gphys (GPhys) : a GPhys whose data is plotted.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "title"       nil     # Title of the figure(if nil, internally
                             # determined)
       "annotate"    true    # if false, do not put texts on the right
                             # margin even when newframe==true
       "exchange"    false   # whether to exchange x and y axes
       "index"       1       # mark index
       "type"        2       # mark type
       "size"        0.01    # marks size
       "max"         nil     # maximum data value
       "min"         nil     # minimum data value
       "legend"      nil     # legend to annotate the mark type, index, and
                             # size. nil (defalut -- do not to show); a String
                             # as the legend; true to use the name of the GPhys
                             # as the legend
       "legend_vx"   nil     # (effective if legend) viewport x values of
                             # the lhs of the legend line (positive float); or
                             # nil for automatic settting (shown to the right of
                             # vpt); or move it to the left relatively (negtive
                             # float)
       "legend_vy"   nil     # (effective if legend) viewport y value of the
                             # legend (Float; or nil for automatic settting)
       "legend_size" nil     # (effective if legend) character size of the
                             # legend
       "map_axes"    false   # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "help"        false   # show help message if true

    RETURN VALUE
    * nil

---tone_and_contour(gphys, newframe=true, options=nil)
    Calls ((<tone>)) and ((<contour>)) successively. You can
    specify the options for any of these.

    NOTE:
    * The option keys that are not existent in these methods
      are simply neglected -- thus no spell-check-like feedback
      is made, contrary to the indivisual call of contour or tone.
      Also, only the help menu of ((<tone>)) can be shown.
    * Requires numru-misc-0.0.6 or later.

---contour(gphys, newframe=true, options=nil)
    Contour plot by selecting the first 2 dimensions (with GPhys#first2D)
    if (({gphys})) is more than 3D.

    Contour levels are determined as follows:
    * contour levels are set in this method if not set by
      ((<set_contour_levels>)) or the option (({"levels"})) is specified
      explicitly.
    * When contour levels are set in this method, the option (({"levels"}))
      has the highest precedence. If it is specified, options
      (({"index"})), (({"line_type"})), (({"label"})), and (({"label_height"}))
      are used.
      If (({"levels"})) are not specified, contour levels with a linear
      increment are set by using the options (({"min"})), (({"max"})),
      (({"nlev"})), (({"interval"})), (({"nozero"})), (({"coloring"})),
      (({"clr_min"})), and (({"clr_max"})), which are interpreted by
      DCLExt::((<ud_set_linear_levs>)). The default values
      of the linear level setting can be changed with
      ((<set_linear_contour_options>)).

    ARGUMENTS
    * gphys (GPhys) : a GPhys whose data is plotted.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)) (or ((<map>))),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "title"       nil     # Title of the figure(if nil, internally
                             # determined)
       "annotate"    true    # if false, do not put texts on the right
                             # margin even when newframe==true
       "transpose"   false   # if true, exchange x and y axes
       "exchange"    false   # same as the option transpose
       "map_axes"    false   # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "keep"        false   # Use the contour levels used previously
       "min"         nil     # minimum contour level
       "max"         nil     # maximum contour level
       "nlev"        nil     # number of levels
       "interval"    nil     # contour interval
       "nozero"      nil     # delete zero contour
       "coloring"    false   # set color contours with ud_coloring
       "clr_min"     13      # (if coloring) minimum color number for the
                             # minimum data values
       "clr_max"     99      # (if coloring) maximum color number for the
                             # maximum data values
       "help"        false   # show help message if true
       "levels"      nil     # contour levels (Array/NArray of Numeric)
       "index"       nil     # (if levels) line index(es) (Array/NArray of
                             # integers, Integer, or nil)
       "line_type"   nil     # (if levels) line type(s) (Array/NArray of
                             # integers, Integer, or nil)
       "label"       nil     # (if levels) contour label(s) (Array/NArray of
                             # String, String, true, false, nil). nil is
                             # recommended.
       "label_height"  nil   # (if levels) label height(s)
                             # (Array/NArray of Numeric, Numeric, or nil).
                             #  nil is recommended.

    RETURN VALUE
    * nil

---set_contour_levels(options)
    Set contour levels for ((<contour>)) explicitly by values with the option (({levels})).

    ARGUMENTS
    * options (Hash) : options to change the default behavior.
      The option (({"levels"})) is mandatory (so it is not optional!).
      Supported options are (({"levels"})), (({"index"})),
      (({"line_type"})), (({"label"})), and (({"label_height"})).
      See ((<contour>)) for their description.

---clear_contour_levels
    Clear contour levels set by ((<set_contour_levels>)).

---set_linear_contour_options(options)
    Change the default option values regarding linear contour level
    setting in ((<contour>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options}))
      for ((<contour>)) but supported options here are limited to
      (({"min"})), (({"max"})), (({"nlev"})), (({"interval"})),
      (({"nozero"})), (({"coloring"})), (({"clr_min"})), and (({"clr_max"})).

    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

---next_linear_contour_options(options)
    Similar to ((<set_linear_contour_options>)) but the setting
    is effective only for the next call of ((<contour>)).

---tone(gphys, newframe=true, options=nil)
    Color tone or shading by selecting the first 2 dimensions
    (with GPhys#first2D) if (({gphys})) is more than 3D.

    Tone levels are determined as follows:
    * Tone levels are set in this method if not set by
      ((<set_tone_levels>)) or the option (({"levels"})) (and
      optionally, (({"patterns"}))) is (are) specified explicitly.
    * When contour levels & patterns are set in this method,
       * (({"levels"})) has the highest precedence. If it is specified,
         tone levels and patterns are determined by DCLExt::((<ue_set_tone>)).
         Here, tone patterns can be specified with the option (({"patterns"})).
       * Currently, option (({"patterns"})) is effective only if (({"levels"}))
         is specified. Otherwise, it is ignored and patterns are
         determined internally (by using DCL.uegtlb).
       * If not, a linear tone levels are set if (({"ltone"=true}))
         (this is the default), or shading is made if (({"ltone"=false})).
         Shading is determined by following the parameters in the UDPACK
         in DCL. Therefore, coloring is made if DCL.udpget('ltone')==true
         regardless the option (({"ltone"=false})) here.
         When linear levels are set in this method, options
         (({"min"})), (({"max"})), (({"nlev"})), and (({"interval"}))
         are used if specified, which are interpreted by
         DCLExt::((<ue_set_linear_levs>)).
         Their default values can be changed by
         ((<set_linear_tone_options>)).

    ARGUMENTS
    * gphys (GPhys) : a GPhys whose data is plotted.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)) (or ((<map>))),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "title"       nil     # Title of the figure(if nil, internally
                             # determined)
       "annotate"    true    # if false, do not put texts on the right
                             # margin even when newframe==true
       "ltone"       true    # Same as udpack parameter ltone
       "tonf"        false   # Use DCL.uetonf instead of DCL.uetone
       "tonc"        false   # Use DCL.uetonc instead of DCL.uetone
       "clr_min"     nil     # if an integer (in 10..99) is specified, used as
                             # the color number for the minimum data values.
                             # (the same can be done by setting the uepack
                             # parameter "icolor1")
       "clr_max"     nil     # if an integer (in 10..99) is specified, used as
                             # the color number for the maximum data values.
                             # (the same can be done by setting the uepack
                             # parameter "icolor2")
       "transpose"   false   # if true, exchange x and y axes
       "exchange"    false   # same as the option transpose
       "map_axes"    false   # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "keep"        false   # Use the tone levels and patterns used previously
       "min"         nil     # minimum tone level
       "max"         nil     # maximum tone level
       "nlev"        nil     # number of levels
       "interval"    nil     # contour interval
       "help"        false   # show help message if true
       "levels"      nil     # tone levels  (Array/NArray of Numeric). Works
                             # together with patterns
       "patterns"    nil     # tone patters (Array/NArray of Numeric). Works
                             # together with levels

    RETURN VALUE
    * nil

---color_bar (options=nil)
    * Descroption:
      Draws color bars. Calls (({DCLext.color_bar})).

---set_tone_levels(options)
    Set tone levels for ((<tone>)) explicitly by values.

    ARGUMENTS
    * options (Hash) : options to change the default behavior.
      Supported options are (({"levels"})) and (({"patterns"})).
      Both of them must be specified explicitly (so they are
      not optional!).

---clear_tone_levels
    Clear tone levels set by ((<set_tone_levels>)).

---set_linear_tone_options(options)
    Change the default option values regarding linear tone level
    setting in ((<tone>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options}))
      for ((<tone>)) but supported options here are limited to
      (({"min"})), (({"max"})), (({"nlev"})), and (({"interval"})).

    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

---next_linear_tone_options(options)
    Similar to ((<set_linear_tone_options>)) but the setting
    is effective only for the next call of ((<tone>)).

---vector(fx, fy, newframe=true, options=nil)
    2-D vector plot using DCL_Ext::((<flow_vect>)),
    which scales vectors in physical ("U") coordinates.

    ARGUMENTS
    * fx, fy (GPhys) : represent vectors
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)) (or ((<map>))),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "title"       nil     # Title of the figure(if nil, internally
                             # determined)
       "annotate"    true    # if false, do not put texts on the right
                             # margin even when newframe==true
       "transpose"   false   # if true, exchange x and y axes
       "exchange"    false   # same as the option transpose
       "map_axes"    false   # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "flow_vect"   true    # If true, use DCLExt::flow_vect to draw
                             # vectors; otherwise, DCL::ugvect is used.
       "flow_itr5"   false   # If true, use DCLExt::flow_itr5 to draw
                             # vectors; otherwise, DCLExt::flow_vect or
                             # DCL::ugvect is used.
       "keep"        false   # Use the same vector scaling as in the previous
                             # call. -- Currently, works only when "flow_vect"
                             # is true
       "xintv"       1       # (Effective only if flow_vect) interval of data
                             # sampling in x
       "yintv"       1       # (Effective only if flow_vect) interval of data
                             # sampling in y
       "factor"      1.0     # (Effective only if flow_vect) scaling factor to
                             # strech/reduce the arrow lengths
       "unit_vect"   false   # Show the unit vector
       "max_unit_vect"       false   # (Effective only if flow_vect &&
                             # unit_vect) If true, use the maximum arrows to
                             # scale the unit vector; otherwise, normalize in V
                             # coordinate.
       "help"        false   # show help message if true

    RETURN VALUE
    * nil

=module NumRu::DCLExt

Collection of various compound DCL functions for convenience.
This module is to be separated but temporarily included in ggraph.rb
while it is premature.

==Index
MATH1
* ((<glpack>))
GRPH1
* ((<sgpack>))
* ((<slpack>))
* ((<swpack>))
GRPH2
* ((<uzpack>))
* ((<ulpack>))
* ((<ucpack>))
* ((<uupack>))
* ((<uspack>))
* ((<udpack>))
* ((<uepack>))
* ((<ugpack>))
* ((<umpack>))

==Module Functions

===glpack
---gl_set_params(hash)
    Calls (({DCL.glpset})) multiple times (for each key and val of (({hash}))).

    ARGUMENTS
    * hash (Hash) : combinations of parameter names and values for udpset

    RETURN VALUE
    * a Hash containing the parameter names and their old values that were
      replaced.

    EXAMPLES
    * You can modify parameters temporarily as follows.

        before = DCLExt.gl_set_params({'lmiss'=>true,'rmiss'=>9999.0})
        ....
        DCLExt.gl_set_params(before)     # reset the change

===sgpack
---sg_set_params(hash)
    Calls (({DCL.sgpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===slpack
---sl_set_params(hash)
    Calls (({DCL.slpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===swpack
---sw_set_params(hash)
    Calls (({DCL.swpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===uzpack
---uz_set_params(hash)
    Calls (({DCL.uzpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===ulpack
---ul_set_params(hash)
    Calls (({DCL.ulpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===ucpack
---uc_set_params(hash)
    Calls (({DCL.ucpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===uupack
---uu_set_params(hash)
    Calls (({DCL.uupset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===uspack
---us_set_params(hash)
    Calls (({DCL.uspset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

===udpack
---ud_set_params(hash)
    Calls (({DCL.udpset})) multiple times (for each key and val of (({hash}))).

    ARGUMENTS
    * hash (Hash) : combinations of parameter names and values for udpset

    RETURN VALUE
    * a Hash containing the parameter names and their old values that were
      replaced.

    EXAMPLES
    * You can modify parameters temporarily as follows.

        before = DCLExt.ud_set_params('indxmj'=>4,'lmsg'=>false)
        DCL.udcntz(data)
        DCLExt.ud_set_params(before)     # reset the change

---ud_set_linear_levs(v, options)
    Set contour levels with a constant interval

    ARGUMENTS
    * v : Data values to be fed to udcnt[rz]
    * options (Hash) : option specification by keys and values. Available
      options are
          name   default value   description
          'min'      nil       minimum contour value (Numeric)
          'max'      nil       maximum contour value (Numeric)
          'nlev'     nil       number of levels (Integer)
          'interval' nil       contour interval (Numeric)
          'nozero'   nil       delete zero contour (true/false)
          'coloring' false     set color contours with ud_coloring (true/false)
          'clr_min'  13        (if coloring) minimum color id (Integer)
          'clr_max'  99       (if coloring) maximum color id (Integer)
      Here, (({interval})) has a higher precedence over (({nlev})).
      Since all the default values are nil, only those explicitly specified
      are interpreted. If no option is provided, the levels generated will
      be the default ones set by udcnt[rz] without any level specification.

---ud_set_contour(levels,index=nil,line_type=nil,label=nil,label_height=nil)
    Set contours of at specified levels.

    Normally you do not have to specify (({label})) and (({label_height})).

    It calls DCL.udsclv for each level. So the arguments are basically
    the same as DCL.udsclv, but only levels are mandatory here.

    ARGUMENTS
    * levels (Array, NArray, or Numeric) : contour levels to be set.
      If Numeric, a single level is set.
    * index (Array of integers, Integer, or nil) :
      index(es) of the contours. If it is an Array and its length is
      shorter than that of (({levels})), the same Array is repeated (so
      for instance [1,1,3] is interpreted as [1,1,3,1,1,3,1,1,3,...]).
      If it is a single Integer, all the contour will have the same index.
     If nil, the value of 'indxmn' is used.
    * line_type (Array of integers, Integer, or nil) :
      line type(s) of the contours. If it is an Array and its length is
      shorter than that of (({levels})), the same Array is repeated.
      the length must agree with that of (({levels})).
      If it is a single Integer, all the contour will have the same type.
      If nil, set to be 1.
    * label (Array of String, String, true, false, nil) :
      Label(s) of the contours. If it is an Array and its length is
      shorter than that of (({levels})), the same Array is repeated.
      the length must agree with that of (({levels})).
      If  it is a single String, all the contour will have the same label.
      If true, all the contours will have the labels representing the levels.
      If false, no label will be drawn (set to "").
      If nil, same as true for the contours whose index is equal to "INDXMJ",
      and same as false otherwise.
    * label_height (Array of Numeric, Numeric, or nil) :
      Heigh of Labels. Normally you do not have to use this.
      If it is an Array and its length is
      shorter than that of (({levels})), the same Array is repeated.
      If nil, the default value ("RSIZEL") is used for non-empty labels.
      If a single Numeric, the same value is used for all the contours.
      Note that it is recommended to not to use this parameter but
      use DCL.udpset('RZISEL'. label_height), since a positive value
      here always means to draw labels even when the label is empty.

    RETURN VALUE
    * nil

---ud_add_contour(levels,index=nil,line_type=nil,label=nil,label_height=nil)
    Same as ((<ud_set_contour>)), but does not clear the contour levels that have
    been set.

===uepack
---ue_set_params(hash)
    Calls (({DCL.uepset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

---ue_set_linear_levs(v, options)
    Set tone levels with a constant interval

    ARGUMENTS
    * v : Data values to be fed to udcnt[rz]
    * options (Hash) : option specification by keys and values. Available
      options are
          name   default value   description
          'min'      nil         minimum tone level (Numeric)
          'max'      nil         maximum tone level (Numeric)
          'nlev'     nil         number of levels (Integer)
          'interval' nil         tone-level interval (Numeric)
      Here, (({interval})) has a higher precedence over (({nlev})).
      Since all the default values are nil, only those explicitly specified
      are interpreted. If no option is provided, the levels generated will
      be the default ones set by udcnt[rz] without any level specification.

---ue_set_tone(levels, patterns)
    Set tone levels and patterns.

    patterns are set between levels as follows:

     when (levels.length == patterns.length+1)

       levels[0]  |  levels[1]  |  levels[2]  ...  |  levels[-2]  |  levels[-1]
              patterns[0]   patterns[1]   ...  patterns[-2]   patterns[-1]

     when (levels.length == patterns.length)

       levels[0]  |  levels[1]  |  levels[2]  ...  |  levels[-1]  |  +infty
              patterns[0]   patterns[1]   ...  patterns[-2]   patterns[-1]

     when (levels.length == patterns.length-1)

       -infty  |  levels[0]  |  levels[1]  ...  |  levels[-1]  |  +infty
           patterns[0]   patterns[1]   ...  patterns[-2]   patterns[-1]

     else
       error (exception raised)

    ARGUMENTS
    * levels (Array or NArray of Numeric) : tone levels. Its length must be
      either 1 larger than, equal to, or 1 smaller than the length of patterns
    * patterns (Array or NArray of Numeric) : tone patterns

    RETURN VALUE
    * nil

---ue_add_tone(levels, patterns)
    Same as ((<ue_set_tone>)), but does not clear the tone levels that have
    been set.

===ugpack
---ug_set_params(hash)
    Calls (({DCL.ugpset})) multiple times (for each key and val of (({hash}))).
    See ((<gl_set_params>)) for usage.

===umpack
---um_set_params(hash)
    Calls (({DCL.umpset})) multiple times (for each key and val of (({hash}))).

    See ((<gl_set_params>)) for usage.

==Original methods:

===Longitude/Latitude Axes
---lon_ax( options=nil )

    Draw longitude axis. (label format: degrees + 'E' or 'W')

    ARGUMENTS
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "yax"         false   # true => draw y-axis, false => draw x-axis
       "cside"       nil     # "b", "t", "l", "r",
                             # nil (=>left/bottom), or false (=>right/top)
       "dtick1"      nil     # Interval of small tickmark
                             #             (if nil, internally determined)
       "dtick2"      nil     # Interval of large tickmark with labels
                             #             (if nil, internally determined)

---lat_ax( options=nil )

    Draw latitude axis. (label format: degrees + 'N' or 'S')

    ARGUMENTS
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "xax"         false   # true => draw x-axis, false => draw y-axis
       "cside"       nil     # "b", "t", "l", "r",
                             # nil (=>left/bottom), or false (=>right/top)
       "dtick1"      nil     # Interval of small tickmark
                             #             (if nil, internally determined)
       "dtick2"      nil     # Interval of large tickmark with labels
                             #             (if nil, internally determined)

===Vectors
---unit_vect( vxfxratio, vyfyratio, fxunit=nil, fyunit=nil, options=nil )

    Show the "unit vector", which indicate the vector scaling.

    ARGUMENTS
    * vxfxratio (Float) : (V cood length)/(actual length) in x
    * vyfyratio (Float) : (V cood length)/(actual length) in y
    * fxunit (Float) : If specified, x unit vect len
    * fyunit (Float) : If specified, y unit vect len
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name   default value   # description:
       "vxunit"      0.05    # x unit vect len in V coord. Used only when
                             # fxunit is omitted (default)
       "vyunit"      0.05    # y unit vect len in V coord. Used only when
                             # fyunit is omitted (default)
       "vxuloc"      nil     # Starting x position of unit vect
       "vyuloc"      nil     # Starting y position of unit vect
       "vxuoff"      0.05    # Specify vxuloc by offset from right-bottom
                             # corner
       "vyuoff"      0.0     # Specify vyuloc by offset from right-bottom
                             # corner
       "inplace"     true    # Whether to print labels right by the unit
                             # vector (true) or below the x axis (false)
       "rsizet"      nil     # Label size(default taken from uz-parameter
                             # 'rsizel1')
       "index"       3       #  Line index of the unit vector
       "help"        false   # show help message if true

---set_unit_vect_options(options)
    Change the default option values for ((<unit_vect>)).

---next_unit_vect_options(options)
    Set the option values effective only in the next call of ((<unit_vect>))

---flow_vect( fx, fy, factor=1.0, xintv=1, yintv=1)

    2D Vector plot. Unlike (({DCL::ugvect})), scaling are made in term of the physical (or "U") coordinate.

    This method is meant to substitute (({DCL::ugvect})). The scaling
    is made in terms of the U coordinate. This method is suitable to
    show vectors such as velocity, since the arrow direction represets
    the direction in the U coordinate. Also, one can re-scale the
    vector length easily by using the argument (({factor})).

    Currently, this method is not compatible with map projection,
    since it calls (({DCL::ugvect})) internally.

    ARGUMENTS
    * fx, fy (2D NArray or Array) : the vector field.
    * factor (Integer) : factor to change the arrow length.
      By default, arrows are scaled so that the longest one
      match the grid interval.
    * xintv, yintv (Interger) : interval to thin out (({fx})) and (({fy})),
      respectively. Useful if the grid points are too many.

---flow_itr5( fx, fy, factor=1.0, unit_vect=false )

    2D Vector plot on the polar coodinate.

    This method just perform rotatation of the vector in U-coordinate
    to N-coordinate and passed to DCL.ugvect.

    ARGUMENTS
    * fx, fy (2D GPhys) : the vector field.
    * factor (Integer)  : factor for scaling in ugvect. When it equals 1,
      vector field will be scaled in DCL.ugvect automatically.
    * unit_vect()       : Show the unit vector

===Color bars
---set_color_bar_options(options)
    To set options of ((<color_bar>)) effective in the rest.

---color_bar(options=nil)
    * Descroption:
      Draws color bars

    * Example
      Here is the simplest case, where no argument is given to color_bar.

        DCL.uetone(hoge)
        DCL.usdaxs
        ...
        DCL.color_bar

      This draws a color bar by using the levels and tone patterns(colors)
      set previously. There are many parameters you can set manually,
      as introduced below:

    * Description of options
       option name   default value   # description:
       "levels"      nil     # tone levels (if omitted, latest ones are used)
       "patterns"    nil     # tone patterns (~colors) (if omitted, latest
                             # ones are used)
       "voff"        nil     # how far is the bar from the viewport in the V
                             # coordinate
       "vcent"       nil     # center position of the bar in the V coordinate
                             # (VX or VY)
       "vlength"     0.3     # bar length in the V coordinate
       "vwidth"      0.02    # bar width in the V coordinate
       "landscape"   false   # if true, horizonlly long (along x axes)
       "portrait"    true    # if true, vertically long (along y axes)
       "top"         false   # place the bar at the top (effective if
                             # landscape)
       "left"        false   # place the bar in the left (effective if
                             # portrait)
       "units"       nil     # units of the axis of the color bar
       "title"       nil     # title of the color bar
       "tickintv"    1       # 0,1,2,3,.. to specify how frequently the
                             # dividing tick lines are drawn (0: no tick lines,
                             # 1: every time, 2: ever other:,...)
       "labelintv"   nil     # 0,1,2,3,.. to specify how frequently labels are
                             # drawn (0: no labels, 1: every time, 2: ever
                             # other:,... default: internally determined)
       "labels_ud"   nil     # user-defined labels for replacing the default
                             # labels (Array of String)
       "charfact"    0.9     # factor to change the label/units/title character
                             # size (relative to 'rsizel1'/'rsizel1'/'rsizec1')
       "log"         false   # set the color bar scale to logarithmic
       "constwidth"  false   # if true, each color is drawn with the same width
       "index"       nil     # line index of tick lines and bar frame
       "charindex"   nil     # line index of labels, units, and title
       "chval_fmt"   nil     # string to specify the DCL.chval format for
                             # labeling
       "help"        false   # show help message if true

=end
############################################################

module NumRu

  module DCLExt
    # to be included in the RubyDCL distribution

    module_function

    #<<< for many packages >>>

    %w!gl sg sl sw uz ul uc uu us ud ue ug um!.each do |pkg|
      eval <<-EOS, nil, __FILE__, __LINE__+1
        def #{pkg}_set_params(hash)
          before = Hash.new
          hash.each{|k,v|
            before[k]=DCL.#{pkg}pget(k)
            if(v.is_a? String) then
              DCL.#{pkg}cset(k,v)
            else
              DCL.#{pkg}pset(k,v)
            end
          }
          before
        end
      EOS
    end

    #<<< module data >>>

    @@empty_hash = Hash.new

    #<<< udpack >>>

    def ud_coloring(clr_min=13, clr_max=99)
      # change the colors of existing contours to make a gradation
      # (rainbow colors with the default color map).
      nlev = DCL.udqcln
      cont_params = Array.new
      for i in 1..nlev
        cont_params.push( DCL.udqclv(i) )   # => [zlev,indx,ityp,clv,hl]
      end
      DCL.udiclv     # clear the contours

      colors = clr_min +
               NArray.int(nlev).indgen! * (clr_max-clr_min) / nlev

      cont_params.sort!
      for i in 0...nlev
        cont_params[i][1] += colors[i]*10   # indx += colors[i]*10
        DCL.udsclv(*cont_params[i])
      end
    end

    def ud_set_linear_levs(v, options=nil)
      #Accepted options
      #  name        default  description
      #  'min'       nil      minimum contour value (Numeric)
      #  'max'       nil      maximum contour value (Numeric)
      #  'nlev'      nil      number of levels (Integer)
      #  'interval'  nil      contour interval (Numeric)
      #  'nozero'    false    delete zero contour (true/false)
      #  'coloring'  false    set color contours with ud_coloring (true/false)
      #  'clr_min'   13       (if coloring) minimum color  number for the
      #                       maximum data values (Integer)
      #  'clr_max'   99      (if coloring) maximum color number for the
      #                       maximum data values (Integer)
      options = @@empty_hash if !options
      raise TypeError, "options must be a Hash" if !options.is_a?(Hash)
      min = options['min']
      max = options['max']
      nlev = options['nlev']
      interval = options['interval']
      nozero = options['nozero']
      if interval
        dx = interval
      elsif nlev
        dx = -nlev
      else
        dx = 0
      end
      if min || max
        min = v.min if !min
        max = v.max if !max
        DCL.udgcla(min, max, dx)
      else
        DCL.udgclb(v, dx)
      end
      if nozero
        DCL.uddclv(0.0)
      end
      if options['coloring']
        clr_min = ( options['clr_min'] || 13 )
        clr_max = ( options['clr_max'] || 99 )
        ud_coloring( clr_min, clr_max )
      end
    end

    def ud_set_contour(*args)
      DCL.udiclv
      ud_add_contour(*args)
    end

    def ud_add_contour(levels,index=nil,line_type=nil,label=nil,label_height=nil)

      # < check levels >
      case levels
      when Array, NArray
        # This is expected. Nothing to do.
      when Numric
        levels = [levels]
      else
        raise ArgumentError, "invalid level specification (#{levels})"
      end

      nlev = levels.length

      # < index >
      index = index.to_a if index.is_a?(NArray)
      case index
      when Array
        raise ArgumentError, "index is an empty array" if index.length == 0
        while (index.length < nlev )
          index += index
        end
      when Numeric
        index = [index]*nlev
      when nil
        index = [DCL.udpget('indxmn')]*nlev
      else
        raise ArgumentError, "unsupported index type (#{index.class})"
      end

      # < line_type >
      line_type = line_type.to_a if line_type.is_a?(NArray)
      case line_type
      when Array
        raise ArgumentError, "line_type is an empty array" if line_type.length == 0
        while (line_type.length < nlev )
          line_type += line_type
        end
      when Numeric
        line_type = [line_type]*nlev
      when nil
        line_type = [1]*nlev
      else
        raise ArgumentError, "unsupported index type (#{index.class})"
      end

      # < label >
      label = label.to_a if label.is_a?(NArray)
      case label
      when Array
        raise ArgumentError, "label is an empty array" if label.length == 0
        while (label.length < nlev )
          label += label
        end
      when String
        label = [label]*nlev
      when false
        label = [""]*nlev
      when true
        label = (0...nlev).collect{|i|
            DCL.udlabl(levels[i])
        }
      when nil
        indxmj = DCL.udpget('indxmj')
        label = (0...nlev).collect{|i|
          if index[i]==indxmj
            DCL.udlabl(levels[i])
          else
            ""
          end
        }
      else
        raise ArgumentError, "unsupported index type (#{index.class})"
      end

      # < label_height >
      label_height = label_height.to_a if label_height.is_a?(NArray)
      case label_height
      when Array
        raise ArgumentError, "label_height is an empty array" if label_height.length == 0
        while (label_height.length < nlev )
          label_height += label_height
        end
      when Numeric
        label_height = [label_height]*nlev
      when nil
        label_height = label.collect{|lv| lv=="" ? 0.0 : DCL.udpget('rsizel')}
      else
        raise ArgumentError, "unsupported index type (#{index.class})"
      end

      # < set levels >

      for i in 0...nlev
        DCL.udsclv(levels[i],index[i],line_type[i],label[i],label_height[i])
      end
      nil
    end

    #<<< uepack >>>

    def ue_set_linear_levs(v, options=nil)
      #  'min'       nil      minimum tone level (Numeric)
      #  'max'       nil      maximum tone level (Numeric)
      #  'nlev'      nil      number of levels (Integer)
      #  'interval'  nil      tone-level interval (Numeric)
      options = @@empty_hash if !options
      raise TypeError, "options must be a Hash" if !options.is_a?(Hash)
      min = options['min']
      max = options['max']
      nlev = options['nlev']
      interval = options['interval']
      if interval
        dx = interval
      elsif nlev
        dx = -nlev
      else
        dx = 0
      end
      if min || max
        min = v.min if !min
        max = v.max if !max
        DCL.uegtla(min, max, dx)
      else
        DCL.uegtlb(v, dx)
      end
    end

    def ue_set_tone(levels, patterns)
      DCL.ueitlv
      ue_add_tone(levels, patterns)
    end

    def ue_add_tone(levels, patterns)

      # < check types >

      if !levels.is_a?(Array) && !levels.is_a?(NArray)
        raise TypeError, "levels: Array or NArray expected (#{levels.inspect})"
      end
      if !patterns.is_a?(Array) && !patterns.is_a?(NArray)
        raise TypeError, "patterns: Array or NArray expected (#{patterns.inspect})"
      end

      # < set levels >

      nlev = levels.length
      npat = patterns.length

      case (nlev - npat)
      when 1
        for i in 0...nlev-1
          DCL.uestlv(levels[i],levels[i+1],patterns[i])
        end
      when 0
        for i in 0...nlev-1
          DCL.uestlv(levels[i],levels[i+1],patterns[i])
        end
        DCL.uestlv(levels[-1],DCL.glpget('rmiss'),patterns[-1])
      when -1
        DCL.uestlv(DCL.glpget('rmiss'),levels[0],patterns[0])
        for i in 1...nlev
          DCL.uestlv(levels[i-1],levels[i],patterns[i])
        end
        DCL.uestlv(levels[-1],DCL.glpget('rmiss'),patterns[-1])
      else
        raise ArgumentError,
          "lengths of levels(#{nlev}) and patterns(#{npat}) are inconsistent"
      end
      nil
    end

    ############################################################
    # RELATIVELY INDEPENDENT OF DCL SUBLIBRARIES
    ############################################################

    # <<< longitude/latitude axes package >>>

    @@lon_ax_options = Misc::KeywordOptAutoHelp.new(
      ['yax', false, 'true => y-axis, false => x-axis'],
      ['cside', nil, '"b", "t", "l", "r", nil (=>left/bottom), or false (=>right/top)'],
      ['dtick1', nil, 'Interval of small tickmark (if nil, internally determined)'],
      ['dtick2', nil, 'Interval of large tickmark with labels (if nil, internally determined)']
    )

    def lon_ax(options=nil)
      opt = @@lon_ax_options.interpret(options)

      yax = opt['yax']
      xax = !yax
      if xax
        xy='x'
      else
        xy='y'
      end

      if opt['cside']
        cside = opt['cside']
      elsif opt['cside'].nil?
        if xax
          cside='b'
        else
          cside='l'
        end
      else
        if xax
          cside='t'
        else
          cside='r'
        end
      end

      vxmin, vxmax, vymin, vymax = DCL.sgqvpt
      uxmin, uxmax, uymin, uymax = DCL.sgqwnd
      if xax
        vmin, vmax = [vxmin,vxmax].min, [vxmin,vxmax].max
        umin, umax = [uxmin,uxmax].min, [uxmin,uxmax].max
      else
        vmin, vmax = [vymin,vymax].min, [vymin,vymax].max
        umin, umax = [uymin,uymax].min, [uymin,uymax].max
      end

      # get dtick1 & dtick2
      dtick1 = opt['dtick1']
      dtick2 = opt['dtick2']
      unless dtick1 && dtick2
        irota = DCL.uzpget("irotl#{xy}#{cside}")
        irota += 1 if yax
        mode = irota.modulo(2)
        DCL.ususcu(xy.capitalize,umin,umax,vmin,vmax,mode)
        dtick1 = DCL.uspget("d#{xy}t") unless dtick1
        dtick2 = DCL.uspget("d#{xy}l") unless dtick2
      end

      lepsl = DCL.glpget('lepsl')
      repsl = DCL.glpget('repsl')
      DCL.glpset('lepsl',true)

      # generate numbers for small tickmarks
      nn = 0
      rx = DCL.irle(umin/dtick1)*dtick1
      if DCL.lreq(umin,rx)
        x = rx
      else
        x = rx + dtick1
      end
      u1 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick1*repsl*nn
          x = 0.0
        end
        u1[nn] = x
        nn = nn + 1
        x = x + dtick1
      end

      # generate numbers for large tickmarks and labels
      nn = 0
      rx = DCL.irle(umin/dtick2)*dtick2
      if DCL.lreq(umin,rx)
        x = rx
      else
        x = rx + dtick2
      end
      u2 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick2*repsl*nn
          x = 0
        end
        u2[nn] = x
        nn = nn + 1
        x = x + dtick2
      end

      # generate labels
      c2 = NArray.to_na(u2)
      c2[c2.gt(180)] -= 360.0
      c2[c2.lt(-180)] += 360.0
      c2[c2.eq(-180)] = 180.0
      c2 = c2.to_a.collect do |c|
        if c == 0 || c == 180
          c.to_i.to_s
        elsif c > 0
          c.to_i.to_s + 'E'
        else
          c.abs.to_i.to_s + 'W'
        end
      end
      nc = c2.collect{|c| c.size}.max

      # call DCL.u[xy]axlb
      if xax
       DCL.uxaxlb(cside,u1,u2,c2,nc)
      else
       DCL.uyaxlb(cside,u1,u2,c2,nc)
      end
    end

    @@lat_ax_options = Misc::KeywordOptAutoHelp.new(
      ['xax', false, 'true => x-axis, false => y-axis'],
      ['cside', nil, '"b", "t", "l", "r", nil (=>left/bottom), or false (=>right/top)'],
      ['dtick1', nil, 'Interval of small tickmark (if nil, internally determined)'],
      ['dtick2', nil, 'Interval of large tickmark with labels (if nil, internally determined)']
    )

    def lat_ax(options=nil)
      opt = @@lat_ax_options.interpret(options)

      xax = opt['xax']
      yax = !xax
      if xax
        xy='x'
      else
        xy='y'
      end

      if opt['cside']
        cside = opt['cside']
      elsif opt['cside'].nil?
        if xax
          cside='b'
        else
          cside='l'
        end
      else
        if xax
          cside='t'
        else
          cside='r'
        end
      end

      vxmin, vxmax, vymin, vymax = DCL.sgqvpt
      uxmin, uxmax, uymin, uymax = DCL.sgqwnd
      if xax
        vmin, vmax = [vxmin,vxmax].min, [vxmin,vxmax].max
        umin, umax = [uxmin,uxmax].min, [uxmin,uxmax].max
      else
        vmin, vmax = [vymin,vymax].min, [vymin,vymax].max
        umin, umax = [uymin,uymax].min, [uymin,uymax].max
      end

      # get dtick1 & dtick2
      dtick1 = opt['dtick1']
      dtick2 = opt['dtick2']
      unless dtick1 && dtick2
        irota = DCL.uzpget("irotl#{xy}#{cside}")
        irota += 1 if yax
        mode = irota.modulo(2)
        DCL.ususcu(xy.capitalize,umin,umax,vmin,vmax,mode)
        dtick1 = DCL.uspget("d#{xy}t") unless dtick1
        dtick2 = DCL.uspget("d#{xy}l") unless dtick2
      end

      lepsl = DCL.glpget('lepsl')
      repsl = DCL.glpget('repsl')
      DCL.glpset('lepsl',true)

      # generate numbers for small tickmarks
      nn = 0
      rx = DCL.irle(umin/dtick1)*dtick1
      if DCL.lreq(umin,rx)
        x = rx
      else
        x = rx + dtick1
      end
      u1 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick1*repsl*nn
          x = 0.0
        end
        u1[nn] = x
        nn = nn + 1
        x = x + dtick1
      end

      # generate numbers for large tickmarks and labels
      nn = 0
      rx = DCL.irle(umin/dtick2)*dtick2
      if DCL.lreq(umin,rx)
        x = rx
      else
        x = rx + dtick2
      end
      u2 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick2*repsl*nn
          x = 0
        end
        u2[nn] = x
        nn = nn + 1
        x = x + dtick2
      end

      # generate labels
      c2 = NArray.to_na(u2)
      c2 = c2.to_a.collect do |c|
        if c == 0
          'EQ'
        elsif c > 0
          c.to_i.to_s + 'N'
        else
          c.abs.to_i.to_s + 'S'
        end
      end
      nc = c2.collect{|c| c.size}.max

      # call DCL.u[xy]axlb
      if xax
        DCL.uxaxlb(cside,u1,u2,c2,nc)
      else
        DCL.uyaxlb(cside,u1,u2,c2,nc)
      end
    end

    # <<< flow vector package >>>

    def __truncate(float, order=2)
      # truncate (round) a floating number with the number digits
      # specified by "order".
      # e.g., if order=3, -0.012345 => -0.0123;  6.6666 => 6.67
      exponent = 10**(-Math::log10(float.abs).floor+order-1)
      (float * exponent).round.to_f/exponent
    end

    @@unit_vect_options = Misc::KeywordOptAutoHelp.new(
      ['vxunit', 0.05, "x unit vect len in V coord. Used only when fxunit is omitted (default)"],
      ['vyunit', 0.05, "y unit vect len in V coord. Used only when fyunit is omitted (default)"],
      ['vxuloc', nil, "Starting x position of unit vect"],
      ['vyuloc', nil, "Starting y position of unit vect"],
      ['vxuoff', 0.05, "Specify vxuloc by offset from right-bottom corner"],
      ['vyuoff', 0.0, "Specify vyuloc by offset from right-bottom corner"],
      ['inplace',true, "Whether to print labels right by the unit vector (true) or below the x axis (false)"],
      ['rsizet', nil, "Label size(default taken from uz-parameter 'rsizel1')"],
      ['index',  3," Line index of the unit vector"]
    )

    def set_unit_vect_options(options)
      @@unit_vect_options.set(options)
    end

    @@next_unit_vect_options = nil
    def next_unit_vect_options(options)
      if options.is_a?(Hash)
        @@next_unit_vect_options = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def unit_vect( vxfxratio,   # (V cood length)/(actual length) in x
                   vyfyratio,   # (V cood length)/(actual length) in y
                   fxunit=nil,  # If specified, x unit vect len
                   fyunit=nil,  # If specified, y unit vect len
                   options=nil )
      #< options >
      if @@next_unit_vect_options
        options = ( options ? @@next_unit_vect_options.update(options) :
                              @@next_unit_vect_options )
        @@next_unit_vect_options = nil
      end
      opt = @@unit_vect_options.interpret(options)
      vxunit = opt['vxunit']
      vyunit = opt['vyunit']
      vxuloc = opt['vxuloc']
      vyuloc = opt['vyuloc']
      rsizet = opt['rsizet']
      index = opt['index']

      #< unit vector >
      if fxunit
        vxunit = vxfxratio * fxunit
      else
        fxunit = vxunit / vxfxratio
      end
      if fyunit
        vyunit = vyfyratio * fyunit
      else
        fyunit = vyunit / vyfyratio
      end
      fxunit = __truncate( (uxusv=fxunit) )
      fyunit = __truncate( (uyusv=fyunit) )
      vxunit = vxunit * (fxunit/uxusv)
      vyunit = vyunit * (fyunit/uyusv)
      if !(vxuloc && vyuloc)
        vx0,vx1,vy0,vy1 = DCL.sgqvpt
        vxuloc = vx1 + opt['vxuoff'] if !vxuloc
        vyuloc = vy0 + opt['vyuoff'] if !vyuloc
      end
      DCL.sglazv( vxuloc, vyuloc,  vxuloc+vxunit, vyuloc,        1, index )
      DCL.sglazv( vxuloc, vyuloc,  vxuloc,        vyuloc+vyunit, 1, index )

      #< labelling >
      sfxunit = sprintf("%.2g",fxunit)
      sfyunit = sprintf("%.2g",fyunit)
      rsizet = DCL.uzpget('rsizel1') if !rsizet
      if opt['inplace']
        DCL.sgtxzv(vxuloc, vyuloc-1.2*rsizet,
                   sfxunit, rsizet, 0, -1, index)
        DCL.sgtxzv(vxuloc+1.2*rsizet, vyuloc+0.5*rsizet,
                   sfyunit, rsizet, 90, -1, index)
      else
        msg= "UNIT VECTOR X:#{sfxunit} Y:#{sfyunit}"
        before = uz_set_params({'rsizec1'=>rsizet})
        DCL.uxsttl('b',' ',0.0)
        DCL.uxsttl('b',msg,0.0)
        uz_set_params(before)
      end
    end

    def flow_vect( fx, fy, factor=1.0, xintv=1, yintv=1,
                   vxfxratio=nil, vyfyratio=nil)
      raise ArgumentError,"Expect 2D arrays" if fx.rank != 2 || fy.rank != 2
      raise ArgumentError,"fx.shape != fy.shape" if fx.shape != fy.shape
      raise ArgumentError,"xintv must be a positive integer" if xintv < 0
      raise ArgumentError,"yintv must be a positive integer" if yintv < 0
      nx, ny = fx.shape
      if xintv >= 2
        idx = NArray.int(nx/xintv).indgen!*xintv  # [0,xintv,2*xintv,..]
        fx = fx[idx, true]
        fy = fy[idx, true]
      end
      if yintv >= 2
        idx = NArray.int(ny/yintv).indgen!*yintv  # [0,yintv,2*yintv,..]
        fx = fx[true, idx]
        fy = fy[true, idx]
      end
      nx, ny = fx.shape  # again, because of xintv & yintv
      vx0,vx1,vy0,vy1 = DCL.sgqvpt
      wnd = DCL.sgqwnd
      if wnd.include?(DCL.glrget('rundef'))
        ux0,ux1,uy0,uy1 = DCL.sgqtxy
      else
        ux0,ux1,uy0,uy1 = wnd
      end
      dvx = (vx1-vx0)/nx
      dvy = (vy1-vy0)/ny
      ax = (vx1-vx0)/(ux1-ux0)   # factor to convert from U to V coordinate
      ay = (vy1-vy0)/(uy1-uy0)   # factor to convert from U to V coordinate
      fxmx = fx.abs.max
      fymx = fy.abs.max
      raise "fx has no data or all zero" if fxmx == 0
      raise "fy has no data or all zero" if fymx == 0
      cn = [ dvx/(ax*fxmx),  dvy/(ay*fymx) ].min  # normarization constant
      vxfxratio = factor*cn*ax if !vxfxratio
      vyfyratio = factor*cn*ay if !vyfyratio
      before = ug_set_params( {'LNRMAL'=>false, 'LMSG'=>false,
                               'XFACT1'=>1.0, 'YFACT1'=>1.0} )
      DCL.ugvect( vxfxratio*fx, vyfyratio*fy )
      ug_set_params( before )
      unit_vect_info = [ vxfxratio, vyfyratio, fxmx, fymx ]
      return unit_vect_info
    end

    def flow_itr5( gpx, gpy, factor=1.0, unit_vect=false )
      raise ArgumentError,"Expect 2D arrays" if gpx.rank != 2 || gpy.rank != 2
      raise ArgumentError,"gpx.shape != gpy.shape" if gpx.shape != gpy.shape

      raise "Transform. No. should be 5" if DCL.sgpget('itr') != 5

      theta = gpx.coord(1) / 180 * Math::PI
      theta = theta.reshape(1,theta.shape[0])

      vx = gpx * theta.cos - gpy * theta.sin   # UC component -> VC
      vy = gpx * theta.sin + gpy * theta.cos   # UC component -> VC

      DCL.sglset('LCLIP',false)
      before1 = DCLExt.ug_set_params(
                   {'LUNIT'=>true, 'LUMSG'=>true} ) if unit_vect
      before2 = DCLExt.ug_set_params(
                   {'LNRMAL'=>false,
                    'XFACT1'=>factor, 'YFACT1'=>factor} ) if factor != 1.0
      DCL.ugvect( vx.val, vy.val )

      if unit_vect
        uxunit = sprintf("%.2g",DCL.ugrget('UXUNIT'))
        uyunit = sprintf("%.2g",DCL.ugrget('UXUNIT'))
        vxuloc = DCL.ugrget('VXULOC')
        vyuloc = DCL.ugrget('VYULOC')
        rsize  = DCL.ugrget('RSIZET')
        dv = rsize
        DCL.sgtxzv(vxuloc, vyuloc-dv, uxunit, rsize,  0, -1, 3 )
        DCL.sgtxzv(vxuloc-dv, vyuloc, uyunit, rsize, 90, -1, 3 )
      end

      ug_set_params( before2 ) if factor != 1.0
      ug_set_params( before1 ) if unit_vect
    end

    ######################################

    # <<< color bar >>>

    @@color_bar_options =  Misc::KeywordOptAutoHelp.new(
      ["levels",  nil, "tone levels (if omitted, latest ones are used)"],
      ["patterns", nil, "tone patterns (~colors) (if omitted, latest ones are used)"],
      ["voff", nil, "how far is the bar from the viewport in the V coordinate"],
      ["vcent",nil, "center position of the bar in the V coordinate (VX or VY)"],
      ["vlength", 0.3, "bar length in the V coordinate"],
      ["vwidth", 0.02, "bar width in the V coordinate"],
      ["landscape", false, "if true, horizonlly long (along x axes)"],
      ["portrait", true, "if true, vertically long (along y axes)"],
      ["top",  false, "place the bar at the top (effective if landscape)"],
      ["left", false, "place the bar in the left (effective if portrait)"],
      ["units", nil, "units of the axis of the color bar"],
      ["title", nil, "title of the color bar"],
      ["tickintv", 1, "0,1,2,3,.. to specify how frequently the dividing tick lines are drawn (0: no tick lines, 1: every time, 2: ever other:,...)"],
      ["labelintv", nil, "0,1,2,3,.. to specify how frequently labels are drawn (0: no labels, 1: every time, 2: ever other:,... default: internally determined)"],
      ["labels_ud", nil, "user-defined labels for replacing the default labels (Array of String)"],
      ["charfact", 0.9, "factor to change the label/units/title character size (relative to 'rsizel1'/'rsizel1'/'rsizec1')"],
      ["log", false, "set the color bar scale to logarithmic"],
      ["constwidth", false, "if true, each color is drawn with the same width"],
      ["index", nil, "index of tick lines and bar frame"],
      ["charindex", nil, "index of labels, units, and title"],
      ["chval_fmt", nil, "string to specify the DCL.chval format for labeling"]
    )

    def set_color_bar_options(options)
      @@color_bar_options.set(options)
    end

    def level_chval_fmt(max,min,dx)
      # returns a format for DCL.chval suitable for color-ba labels
      eps = 1e-4 * dx.abs
      if ( dx.abs % 10**Math::log10(dx.abs) < eps )
        # 1 keta
        least_order = Math::log10(dx.abs).floor
      else
        # >=2 keta --> limit to 2 keta
        least_order = Math::log10(dx.abs).floor - 1
      end
      ng = Math::log10([max.abs,min.abs,eps].max).floor - least_order + 1
      if ng <= 3
        fmt = 'b'
      else
        n = Math::log10([max.abs,min.abs].max).floor
        nn = Math::log10([max.abs,min.abs].min).floor
        if least_order >= 0 and nn >= 0
          ifg = 'i'
        elsif 0 <= n and n <= 4
          ifg = 'f'
        else
          ifg = 'g'
        end
        case(ifg)
        when 'i'
          fmt = '(i15)'
        when 'g'
          ng = Math::log10([max.abs,min.abs,eps].max).floor - least_order + 1
          ng = [ ng, 2 ].max
          fmt = "(g15.#{ng})"
        when 'f'
          nf = [ -least_order, 0].max
          fmt = "(f15.#{nf})"
        end
      end
      fmt
    end

    def sprintf_level(x,max,min,dx)
      # format a float for color-bar labels.
      # like DCL.hval('b',x) but changes according to dx
      if x==0
        fg = 'f'
      else
        n = Math::log10(x.abs).floor
        if 0 <= n and n <= 4
          fg = 'f'
        else
          fg = 'g'
        end
      end
      eps = 1e-6
      if ( dx.abs % 10**Math::log10(dx.abs) < eps )
        # 1 keta
        least_order = Math::log10(dx.abs).floor
      else
        # >=2 keta --> limit to 2 keta
        least_order = Math::log10(dx.abs).floor - 1
      end
      if fg == 'g'
        ng = Math::log10([max.abs,min.abs,eps].max).floor - least_order + 1
        ng = [ ng, 2 ].max
        fmt = "%.#{ng}g"
      else
        nf = [ -least_order, 0].max
        fmt = "%.#{nf}f"
      end
      sprintf(fmt,x).sub(/\.0*$/,'')
    end

    def color_bar(options=nil)

      # < set parameters >
      opt = @@color_bar_options.interpret(options)
      lsetx = DCL.uwqgxz
      lsety = DCL.uwqgyz

      rmiss = DCL.glrget('rmiss')

      levels = opt['levels']
      patterns = opt['patterns']

      if (levels.nil? && !patterns.nil?) || (!levels.nil? && patterns.nil?)
        raise "levels and patterns must be set at same time\n"
      end

      landscape = opt["landscape"] || !opt["portrait"]
      portrait  = ! landscape

      if !levels.nil?
        ue_set_tone(levels,patterns)
      end

      labels_ud = opt["labels_ud"]
      if !labels_ud.nil?
        if labels_ud.class != Array
          raise ArgumentError,"'labels_ud' must be an Array of String"
        elsif labels_ud.size == 0
          raise ArgumentError,"'labels_ud' must be an Array of String"
        else
          labels_ud.each do |lbl_ud|
            if lbl_ud.class != String
              raise ArgumentError,"'labels_ud' must be an Array of String"
            end
          end
        end
      end

      if opt["index"]
        index = opt["index"]
        index = 1 if index <= 0
      else
        index = DCL::uziget("indext2")
      end
      indext1_bk = DCL::uziget("indext1")
      indext2_bk = DCL::uziget("indext2")
      DCL::uziset("indext1",index)
      DCL::uziset("indext2",index)

      if opt["charindex"]
        charindex = opt["charindex"]
        charindex = 1 if charindex <= 0
      else
        charindex = DCL::uziget("indexl1")
      end
      indexl1_bk = DCL::uziget("indexl1")
      DCL::uziset("indexl1",charindex)

      charfact = opt["charfact"]
      rsizel1_bk = DCL::uzrget("rsizel1")
      rsizec1_bk = DCL::uzrget("rsizec1")
      DCL::uzrset("rsizel1",charfact*rsizel1_bk)
      DCL::uzrset("rsizec1",charfact*rsizec1_bk)

      nton = DCL::ueqntl
      if nton==0
        raise "no tone patern was set\n"
      end
      lev1 = Array.new
      lev2 = Array.new
      patterns = Array.new if !opt['patterns']
      for n in 0..nton-1
        tlev1,tlev2,ipat = DCL::ueqtlv(n+1)
        lev1.push(tlev1)
        lev2.push(tlev2)
        patterns.push(ipat) if !opt['patterns']
      end

      #levels = lev1+lev2
      #levels = levels.uniq.sort
      #levels.delete(rmiss)
      #if levels.ne(levels.sort).any?
      #  raise "levels is not in order\n"
      #end

      levels = lev1.push(lev2[-1]) if !levels
      levels = NArray.to_na(levels) if levels.is_a?(Array)
      patterns = NArray.to_na(patterns) if patterns.is_a?(Array)

      vx1, vx2, vy1, vy2 = DCL.sgqvpt

      if opt['log']
        lv = levels[levels.ne(rmiss).where]
        if lv.length >= 4 && lv[0]*lv[-1]<0
          iturn = 0
          for i in 0...levels.length
            if levels[i] != rmiss
              if levels[i]*lv[0] < 0
                iturn = i
                break
              end
            end
          end
          opt['vlength'] /= 2
          vc0 = opt['vcent'] || ( portrait && (vy1+vy2)/2) || (vx1+vx2)/2

          opt["voff"] ||=
                DCL.uzrget('pad1')*DCL::uzrget("rsizec2") +
               ( portrait ? DCL.uzrget('roffyr') : - DCL.uzrget('roffxb') )

          vsep2 = 0.02

          opt['levels']   = levels[0..iturn-1]
          opt['patterns'] = patterns[0..iturn-2]
          opt['vcent'] = vc0 - opt['vlength']/2 - vsep2
          color_bar(opt)

          opt['levels']   = levels[iturn..-1]
          opt['patterns'] = patterns[iturn..-1]
          opt['vcent'] = vc0 + opt['vlength']/2 + vsep2
          color_bar(opt)

          # fill between the two bars
          if portrait
            x1 = vx2 + opt["voff"]
            x2 = x1 + opt['vwidth']
            y1 = vc0 - vsep2
            y2 = vc0 + vsep2
          else
            x1 = vc0 - vsep2
            x2 = vc0 + vsep2
            y1 = vy1 - opt["voff"]
            y2 = y1 - opt['vwidth']
          end
          bk = DCLExt.sg_set_params({'lclip'=>false})
          DCL.sgtnzv([x1,x2,x2,x1],[y1,y1,y2,y2],patterns[iturn-1])
          DCL.sgplzv([x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1],1,3)
          DCLExt.sg_set_params(bk)
          return
        end
      end

      if levels.length <= 1
        $stderr.print( "WARNING #{__FILE__}:#{__LINE__}: # of levels <= 1. No color bar is drawn." )
        return
      end

      itrsv = DCL::sgqtrn
      if itrsv <= 4
        ux1sv, ux2sv, uy1sv, uy2sv = DCL.sgqwnd
      else
        simfacsv, vxoffsv, vyoffsv = DCL.sgqsim
        plxsv, plysv, plrotsv = DCL.sgqmpl()
      end

      vwidth = opt["vwidth"]
      vlength = opt["vlength"]

      if portrait
        if !opt["left"]
          # left
          voff =  opt["voff"] ||
              DCL.uzrget('roffyr') + DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vxmin = vx2 + voff
          vxmax = vx2 + voff + vwidth
        else
          # right
          voff =  opt["voff"] ? -opt["voff"] : \
              DCL.uzrget('roffyl') - DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vxmax = vx1 + voff
          vxmin = vx1 + voff - vwidth
        end
        vymin =( opt["vcent"] ? opt["vcent"]-vlength/2 : vy1 )
        vymax =( opt["vcent"] ? opt["vcent"]+vlength/2 : vy1+vlength )
      else  ## landscape ##
        vxmin =( opt["vcent"] ? opt["vcent"]-vlength/2 : (vx1+vx2)/2-vlength/2 )
        vxmax =( opt["vcent"] ? opt["vcent"]+vlength/2 : (vx1+vx2)/2+vlength/2 )
        if opt["top"]
          # top
          voff =  opt["voff"] ||
               DCL.uzrget('roffxt') + DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vymin = vy2 + voff
          vymax = vy2 + voff + vwidth
        else
          # bottom
          voff =  opt["voff"] ? -opt["voff"] : \
               DCL.uzrget('roffxb') - DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vymax = vy1 + voff
          vymin = vy1 + voff - vwidth
        end
      end

      min = levels[levels.ne(rmiss).where].min
      max = levels[levels.ne(rmiss).where].max
      if levels[0] == rmiss
        inf0 = true
        dummy1,dummy2,ipat0 = DCL::ueqtlv(1)
      else
        inf0 = false
      end
      if levels[-1] == rmiss
        inf1 = true
        dummy1,dummy2,ipat1 = DCL::ueqtlv(nton)
      else
        inf1 = false
      end

      # < paint color tones >

      lclip_bk = DCL::sglget("lclip")
      DCL::sglset("lclip", false)

      if opt["constwidth"]

        if inf0
          levels = levels[1..-1]
          patterns = patterns[1..-1]
        end
        if inf1
          levels = levels[0..-2]
          patterns = patterns[0..-2]
        end
        nlev = levels.length
        npat = patterns.length

        if portrait
          vy = (NArray.sfloat(npat+1).indgen!)*(vymax-vymin)/npat + vymin

          # paint color tones for infinity (with drawing frame)
          if inf0
            vy3 = [vymin, vymin-vwidth*2.25, vymin]
            vx3 = [vxmax, (vxmax+vxmin)/2, vxmin]
            DCL.sgtnzv(vx3,vy3,ipat0)
            DCL.sgplzv(vx3,vy3,1,index)
          end
          if inf1
            vy3 = [vymax, vymax+vwidth*2.25, vymax]
            vx3 = [vxmax, (vxmax+vxmin)/2, vxmin]
            DCL.sgtnzv(vx3,vy3,ipat1)
            DCL.sgplzv(vx3,vy3,1,index)
          end

          # paint color tones for each range (with drawing long-side frame)
          for i in 0..npat-1
            DCL::sgtnzv([vxmin,vxmax,vxmax,vxmin],[vy[i],vy[i],vy[i+1],vy[i+1]],patterns[i])
            DCL::sgplzv([vxmin,vxmin],[vy[i],vy[i+1]],1,index)
            DCL::sgplzv([vxmax,vxmax],[vy[i],vy[i+1]],1,index)
          end

        else ## landscape ##
          vx = (NArray.sfloat(npat+1).indgen!)*(vxmax-vxmin)/npat + vxmin

          # paint color tones for infinity (with drawing frame)
          if inf0
            vx3 = [vxmin, vxmin-vwidth*2.25, vxmin]
            vy3 = [vymax, (vymax+vymin)/2, vymin]
            DCL.sgtnzv(vx3,vy3,ipat0)
            DCL.sgplzv(vx3,vy3,1,index)
          end
          if inf1
            vx3 = [vxmax, vxmax+vwidth*2.25, vxmax]
            vy3 = [vymax, (vymax+vymin)/2, vymin]
            DCL.sgtnzv(vx3,vy3,ipat1)
            DCL.sgplzv(vx3,vy3,1,index)
          end

          # paint color tones for each range (with drawing long-side frame)
          for i in 0..npat-1
            DCL::sgtnzv([vx[i],vx[i],vx[i+1],vx[i+1]],[vymin,vymax,vymax,vymin],patterns[i])
            DCL::sgplzv([vx[i],vx[i+1]],[vymin,vymin],1,index)
            DCL::sgplzv([vx[i],vx[i+1]],[vymax,vymax],1,index)
          end
        end

      else  ### opt["constwidth"] == false ###

        # paint color tones for infinity (with drawing frame)
        if portrait
          if inf0
            vy3 = [vymin, vymin-vwidth*2.25, vymin]
            vx3 = [vxmax, (vxmax+vxmin)/2, vxmin]
            DCL.sgtnzv(vx3,vy3,ipat0)
            DCL.sgplzv(vx3,vy3,1,index)
          end
          if inf1
            vy3 = [vymax, vymax+vwidth*2.25, vymax]
            vx3 = [vxmax, (vxmax+vxmin)/2, vxmin]
            DCL.sgtnzv(vx3,vy3,ipat1)
            DCL.sgplzv(vx3,vy3,1,index)
          end
        else ## landscape ##
          if inf0
            vx3 = [vxmin, vxmin-vwidth*2.25, vxmin]
            vy3 = [vymax, (vymax+vymin)/2, vymin]
            DCL.sgtnzv(vx3,vy3,ipat0)
            DCL.sgplzv(vx3,vy3,1,index)
          end
          if inf1
            vx3 = [vxmax, vxmax+vwidth*2.25, vxmax]
            vy3 = [vymax, (vymax+vymin)/2, vymin]
            DCL.sgtnzv(vx3,vy3,ipat1)
            DCL.sgplzv(vx3,vy3,1,index)
          end
        end

        # paint color tones for each range
        nbar = 100
        bar = NArray.float(nbar,2)
        for i in 0..nbar-1
          bar[i,true] = min + (max-min).to_f/(nbar-1)*i
        end

        xb = DCL::uzlget("labelxb")
        yl = DCL::uzlget("labelyl")
        if portrait
          xmin = 0.0
          xmax = 1.0
          ymin = min
          ymax = max
          DCL::uzlset("labelxb",false)
          DCL::uzlset("labelyl",true)
          bar = bar.transpose(-1,0)
          DCL::uwsgxa([0,1])
          DCL::uwsgya(bar[0,true])
        else
          xmin = min
          xmax = max
          ymin = 0.0
          ymax = 1.0
          DCL::uzlset("labelxb",true)
          DCL::uzlset("labelyl",false)
          DCL::uwsgxa(bar[true,0])
          DCL::uwsgya([0,1])
        end

        type = 1
        if opt["log"]
          type +=1
          type +=1 if !portrait
        end

        DCL::grfig
        DCL::grsvpt(vxmin,vxmax,vymin,vymax)
        DCL::grswnd(xmin,xmax,ymin,ymax)
        DCL::grstrn(type)
        DCL::grstrf

        DCL::uetone(bar)
        DCL.uwsgxz(false)
        DCL.uwsgyz(false)

      end

      # < set ticking and labeling levels >

      if opt["labelintv"]
        labelintv = opt["labelintv"]
      else
        ntn = nton
        ntn -= 1 if inf0
        ntn -= 1 if inf1
        if portrait
          labelintv = (ntn-1) / 9  + 1
        else
          labelintv = (ntn-1) / 5  + 1
        end
      end
      if labelintv <= 0
        no_label = true
        labelintv = 1
      else
        no_label = false
      end

      tickintv = opt["tickintv"]
      if tickintv <= 0
        no_tick = true
        tickintv = labelintv
      else
        no_tick = false
      end

      eps = 1e-5
      dummy = -9.9e-38
      dz = dzp = dzc = dummy
      idu = Array.new
      (1...levels.length).each do |i|
        dzc = (levels[i] - levels[i-1]).abs
        if (dzc-dzp).abs <= eps * [dzc.abs,dzp.abs].max
          dz = dzc  # set dz if two consecutive inrements are the same
          idu.push( i-1 )
        end
        dzp = (levels[i] - levels[i-1]).abs
      end
      if idu.length > 0
        idumin = idu.min - 1
        idumax = idu.max + 1
      else
        idumin = 0
        idumax = levels.length-1
      end
      if dz != dummy
#        if idumin == 1 and levels[0] != rmiss
#          # to correct non-uniform intv at the beginning
#          levels[0] = levels[1] - dz
#          idumin = 0
#          min = levels[0]
#        end
#        if idumax == levels.length-2 and levels[-1] != rmiss
#          # to correct non-uniform intv at the end
#          levels[-1] = levels[-2] + dz
#          idumax = levels.length-1
#          max = levels[-1]
#        end
        # use the algorithm used in DCL.udgcla
        offs_tick = ( (-levels[idumin]/dz).round % tickintv + idumin ) % tickintv
        offs_label = ( (-levels[idumin]/dz).round % labelintv + idumin ) % labelintv
      else
        md = 0
        if ( (idx=levels.eq(0.0).where).length > 0 )
          md = idx[0] % labelintv
        else
          a = levels[0...([labelintv,levels.length].min)]
          b = a * 10**( -NMath.log10(a.abs).floor.min )
          (0...b.length).each{|i| md=i if (b[i].round-b[i]).abs < 1e-5 }
        end
        offs_tick = (md % tickintv)
        offs_label = md
      end

      if levels.length >= 4
        lvmx = levels[1..-2].max
        lvmn = levels[1..-2].min
        dlv = (lvmx-lvmn) / (levels.length-3)
      elsif levels.length == 3 or levels.length == 2
        lvmn = lvmx = dlv = levels[1]
      else
        lvmn = lvmx = dlv = levels[0]
      end

      # < draw units, title, labels, and tick lines>

      if opt["constwidth"]

        if !no_label && labels_ud
          ilbl = 0
          for i in 0..nlev-1
            if (i % labelintv) == offs_label
              ilbl += 1
            end
          end
          if labels_ud.size != ilbl
            raise ArgumentError, "'labels_ud' must be an Array of length==#{ilbl} in this case"
          end
        end

        if portrait

          if voff > 0
            cent = -1
            vxlabel = vxmax+DCL::uzrget('pad1')*DCL::uzrget('rsizel1')
            # title
            DCL::sgtxzr(vxmin-(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizec1'), (vymin+vymax)/2.0, opt['title'], DCL::uzrget('rsizec1'), 90, 0, charindex) if opt['title']
            # units
            DCL::sgtxzr(vxmax+DCL::uzrget('pad1')*DCL::uzrget('rsizel1'), vymax+3.0*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          else
            cent = 1
            vxlabel = vxmin-DCL::uzrget('pad1')*DCL::uzrget('rsizel1')
            # title
            DCL::sgtxzr(vxmax+(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizec1'), (vymin+vymax)/2.0, opt['title'], DCL::uzrget('rsizec1'), -90, 0, charindex) if opt['title']
            # units
            DCL::sgtxzr(vxmin-DCL::uzrget('pad1')*DCL::uzrget('rsizel1'), vymax+3.0*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, 1, charindex) if opt['units']
          end

          ilbl_ud = 0
          for i in 0..nlev-1
            # labels
            if !no_label && (i % labelintv) == offs_label
              if labels_ud
                char = labels_ud[ilbl_ud]
                DCL::sgtxzr(vxlabel,vy[i],char,DCL::uzrget('rsizel1'),0,cent,charindex)
                ilbl_ud += 1
              else
                begin
                  if(opt['chval_fmt'])
                    char = DCL::chval(opt['chval_fmt'],levels[i])
                  else
                    char = sprintf_level(levels[i],lvmx,lvmn,dlv)
                  end
                  DCL::sgtxzr(vxlabel,vy[i],char,DCL::uzrget('rsizel1'),0,cent,charindex)
                rescue
                  DCL::sgtxzr(vxlabel,vy[i],levels[i].to_s,DCL::uzrget('rsizel1'),0,cent,charindex)
                end
              end
            end
            # tick lines and short-side frame
            if (!no_tick && (i % tickintv) == offs_tick) || (!inf0 && i == 0) || (!inf1 && i == nlev-1)
              DCL::sgplzv([vxmin,vxmax],[vy[i],vy[i]],1,index)
            end
          end

        else  ## landscape ##
          if voff > 0
            vylabel = vymax+(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1')
            # title
            DCL::sgtxzr((vxmin+vxmax)/2.0, vymin-(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizec1'), opt['title'], DCL::uzrget('rsizec1'), 0, 0, charindex) if opt['title']
            # units
            DCL::sgtxzr(vxmax+3.0*DCL::uzrget('rsizel1'), vymax+(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          else
            vylabel = vymin-(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1')
            # title
            DCL::sgtxzr((vxmin+vxmax)/2.0, vymax+(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizec1'), opt['title'], DCL::uzrget('rsizec1'), 0, 0, charindex) if opt['title']
            # units
            DCL::sgtxzr(vxmax+3.0*DCL::uzrget('rsizel1'), vymin-(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          end

          ilbl_ud = 0
          for i in 0..nlev-1
            # labels
            if !no_label && (i % labelintv) == offs_label
              if labels_ud
                char = labels_ud[ilbl_ud]
                DCL::sgtxzr(vx[i],vylabel,char,DCL::uzrget('rsizel1'),0,0,charindex)
                ilbl_ud += 1
              else
                begin
                  if(opt['chval_fmt'])
                    char = DCL::chval(opt['chval_fmt'],levels[i])
                  else
                    char = sprintf_level(levels[i],lvmx,lvmn,dlv)
                  end
                  DCL::sgtxzr(vx[i],vylabel,char,DCL::uzrget('rsizel1'),0,0,charindex)
                rescue
                  DCL::sgtxzr(vx[i],vylabel,levels[i].to_s,DCL::uzrget('rsizel1'),0,0,charindex)
                end
              end
            end
            # tick lines and short-side frame
            if (!no_tick && (i % tickintv) == offs_tick) || (!inf0 && i == 0) || (!inf1 && i == nlev-1)
              DCL::sgplzv([vx[i],vx[i]],[vymin,vymax],1,index)
            end
          end
        end

      else  ### opt["constwidth"] == false ###

        inner_bk = DCL::uziget('inner')
        uz_set_params('inner'=>1)

        tick1 = Array.new
        tick2 = Array.new
        for i in 0..levels.length-1
#          if i>=idumin && i<=idumax && levels[i]!=rmiss
          if levels[i]!=rmiss
            tick1.push(levels[i]) if (i % tickintv) == offs_tick
            tick2.push(levels[i]) if (i % labelintv) == offs_label
          end
        end

        if portrait

          if voff > 0
            before = uz_set_params('labelyl'=>false,'labelyr'=>true,'icentyr'=>-1.0)
          else
            before = uz_set_params('labelyl'=>true,'labelyr'=>false,'icentyl'=>1.0)
          end

          # draw frame, tick lines, and labels
          cfmt_bk = DCL::uyqfmt
          if opt["log"]
            fmt = opt['chval_fmt'] || "b"
          else
            fmt = opt['chval_fmt'] || level_chval_fmt(lvmx,lvmn,dlv)
          end
          DCL::uysfmt(fmt)

          rsizet1_bk = DCL::uzrget("rsizet1")
          rsizet2_bk = DCL::uzrget("rsizet2")
          uz_set_params('rsizet1'=>vwidth,'rsizet2'=>0.0)
          if no_label
            nl_labelxt = DCL::uzlget('labelxt')
            nl_labelxb = DCL::uzlget('labelxb')
            nl_labelyl = DCL::uzlget('labelyl')
            nl_labelyr = DCL::uzlget('labelyr')
            uz_set_params('labelxt'=>false,'labelxb'=>false,'labelyl'=>false,'labelyr'=>false)
          end
          if no_tick
            nt_rsizet1 = DCL::uzrget('rsizet1')
            DCL::uzrset("rsizet1",0.0)
          end

          if labels_ud
            if labels_ud.size != tick2.size
              raise ArgumentError, "'labels_ud' must be an Array of length==#{tick2.size} in this case"
            end
            nc = labels_ud.collect{|c| c.size}.max
            DCL::uyaxlb("l",tick1,tick2,labels_ud,nc)
            DCL::uyaxlb("r",tick1,tick2,labels_ud,nc)
          else
            DCL::uyaxnm("l",tick1,tick2)
            DCL::uyaxnm("r",tick1,tick2)
          end
          DCL::uxaxdv("b",1,index) if !inf0
          DCL::uxaxdv("t",1,index) if !inf1

          if no_tick
            DCL::uzrset("rsizet1",nt_rsizet1)
          end
          if no_label
            uz_set_params('labelxt'=>nl_labelxt,'labelxb'=>nl_labelxb,'labelyl'=>nl_labelyl,'labelyr'=>nl_labelyr)
          end
          DCL::uzrset("rsizet1",rsizet1_bk)
          DCL::uzrset("rsizet2",rsizet2_bk)

          DCL::uysfmt(cfmt_bk)

          # units and title
          if voff > 0
            DCL::uysttl("l", opt["title"], 0.0) if opt["title"]
            DCL::sgtxzr(vxmax+DCL::uzrget('pad1')*DCL::uzrget('rsizel1'), vymax+3.0*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          else
            irotcyr_bk = DCL::uziget('irotcyr')
            DCL::uziset('irotcyr', 3)
            DCL::uysttl("r", opt["title"], 0.0) if opt["title"]
            DCL::uziset('irotcyr', irotcyr_bk)
            DCL::sgtxzr(vxmin-DCL::uzrget('pad1')*DCL::uzrget('rsizel1'), vymax+3.0*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, 1, charindex) if opt['units']
          end

          uz_set_params(before)

        else  ## landscape ##

          if voff > 0
            before = uz_set_params('labelxt'=>true,'labelxb'=>false)
          else
            before = uz_set_params('labelxt'=>false,'labelxb'=>true)
          end

          # draw frame, tick lines, and labels
          cfmt_bk = DCL::uxqfmt
          if opt["log"]
            fmt = opt['chval_fmt'] || "b"
          else
            fmt = opt['chval_fmt'] || level_chval_fmt(lvmx,lvmn,dlv)
          end
          DCL::uxsfmt(fmt)

          rsizet1_bk = DCL::uzrget("rsizet1")
          rsizet2_bk = DCL::uzrget("rsizet2")
          uz_set_params('rsizet1'=>vwidth,'rsizet2'=>0.0)
          if no_label
            nl_labelxt = DCL::uzlget('labelxt')
            nl_labelxb = DCL::uzlget('labelxb')
            nl_labelyl = DCL::uzlget('labelyl')
            nl_labelyr = DCL::uzlget('labelyr')
            uz_set_params('labelxt'=>false,'labelxb'=>false,'labelyl'=>false,'labelyr'=>false)
          end
          if no_tick
            nt_rsizet1 = DCL::uzrget('rsizet1')
            DCL::uzrset("rsizet1",0.0)
          end

          if labels_ud
            if labels_ud.size != tick2.size
              raise ArgumentError, "'labels_ud' must be an Array of length==#{tick2.size} in this case"
            end
            nc = labels_ud.collect{|c| c.size}.max
            DCL::uxaxlb("t",tick1,tick2,labels_ud,nc)
            DCL::uxaxlb("b",tick1,tick2,labels_ud,nc)
          else
            DCL::uxaxnm("t",tick1,tick2)
            DCL::uxaxnm("b",tick1,tick2)
          end
          DCL::uyaxdv("l",1,index) if !inf0
          DCL::uyaxdv("r",1,index) if !inf1

          if no_tick
            DCL::uzrset("rsizet1",nt_rsizet1)
          end
          if no_label
            uz_set_params('labelxt'=>nl_labelxt,'labelxb'=>nl_labelxb,'labelyl'=>nl_labelyl,'labelyr'=>nl_labelyr)
          end
          DCL::uzrset("rsizet1",rsizet1_bk)
          DCL::uzrset("rsizet2",rsizet2_bk)

          DCL::uxsfmt(cfmt_bk)

          # units and title
          if voff > 0
            DCL::uxsttl("b", opt["title"], 0.0) if opt["title"]
            DCL::sgtxzr(vxmax+3.0*DCL::uzrget('rsizel1'), vymax+(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          else
            DCL::uxsttl("t", opt["title"], 0.0) if opt["title"]
            DCL::sgtxzr(vxmax+3.0*DCL::uzrget('rsizel1'), vymin-(0.5+DCL::uzrget('pad1'))*DCL::uzrget('rsizel1'), opt['units'], DCL::uzrget('rsizel1'), 0, -1, charindex) if opt['units']
          end

          uz_set_params(before)

        end

        DCL::uzlset("labelxb",xb)
        DCL::uzlset("labelyl",yl)

        DCL::grsvpt(vx1,vx2,vy1,vy2)
        if itrsv <= 4
          DCL::grswnd(ux1sv, ux2sv, uy1sv, uy2sv)
          DCL::grstrn(itrsv)
        else
          DCL.sgssim(simfacsv,vxoffsv,vyoffsv)
          DCL.sgsmpl(plxsv,plysv,plrotsv)
        end
        DCL::grstrf

        uz_set_params('inner'=>inner_bk)
      end

      DCL::uziset("indext1",indext1_bk)
      DCL::uziset("indext2",indext2_bk)
      DCL::uziset("indexl1",indexl1_bk)
      DCL::uzrset("rsizel1",rsizel1_bk)
      DCL::uzrset("rsizec1",rsizec1_bk)

      DCL::sglset("lclip", lclip_bk)
      nil
    end

    # Annotates line/mark type and index (and size if mark).
    # By defualt it is shown in the right margin of the viewport.
    #
    # * str is a String to show
    # * line: true->line ; false->mark
    # * vx: vx of the left-hand point of legend line (or mark position).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    #     * Float && < 0 : move it relatively to the left from the defualt
    # * dx: length of the legend line (not used if mark).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    # * vy: vy of the legend (not used if !first -- see below).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    #     * Float && < 0 : move it relatively lower from the defualt
    # * first : if false, vy is moved lower relatively from the previous vy.
    # * mark_size : size of the mark. if nil, size is used.
    def legend(str, type, index, line=false, size=nil,
               vx=nil, dx=nil, vy=nil, first=true, mark_size=nil)

      size = DCL::uzrget("rsizel1")*0.95 if !size
      mark_size = size if !mark_size

      vpx1,vpx2,vpy1,vpy2 = DCL.sgqvpt
      if first
        if !vy
          vy = vpy2 - 0.04
        elsif vy < 0
          vy = ( vpy2 - 0.04 ) + vy
        end
        @vy = vy
      else
        vy = @vy - 1.5*size
      end

      if !vx
        vx = vpx2 + 0.015
      elsif vx < 0
        vx = (vpx2 + 0.015) + vx
      end

      if line
        dx=0.06 if !dx
        vx2 = vx + dx
        DCL::sgplzv([vx,vx2],[vy,vy],type,index)
        DCL.sgtxzv(vx2+0.01,vy,str,size,0,-1,3)
      else  # --> mark
        DCL::sgpmzv([vx],[vy],type,index,mark_size)
        DCL.sgtxzv(vx+0.015+mark_size*0.5,vy,str,size,0,-1,3)
      end
      nil
    end

    # Driver of quasi_log_levels with data values
    def quasi_log_levels_z(vals, nlev=nil, max=nil, min=nil, cycle=1)
      if max && min
        quasi_log_levels(max.to_f, min.to_f, cycle)
      else
        if nlev
          eps = 0.1
          norder = (nlev-1.0+eps)/cycle
        else
          norder = 3
        end
        mx1 = vals.max
        mx2 = vals.min
        if min && min < 0
          max = min
          min = nil
        elsif max && max < 0
          min = max
          max = nil
        end
        maxsv = max
        minsv = min
        if !max
          max = [ mx1.abs, mx2.abs ].max.to_f
          max = -max if mx1<0
        end
        if !min
          min = max/10**norder
        else
          max = min*10**norder if nlev
        end
        if !(minsv && minsv>0) && !(maxsv && maxsv <0) && ( mx2<0 && mx1>0 )
          min = -min
        end
        quasi_log_levels(max, min, cycle)
      end
    end

    # Returns approximately log-scaled contour/tone levels as well as
    # major/minor flags for contours. No DCL call is made in here.
    #
    # * cycle (Integer; 1, or 2 or 3) : number of level in one-order.
    #   e.g. 1,10,100,.. for cycle==1; 1,3,10,30,.. for cycle==2;
    #   1,2,5,10,20,50,.. for cycle==3
    # * lev0, lev1 (Float) : levels are set between this two params
    #   * if lev0 & lev1 > 0 : positive only
    #   * if lev0 & lev1 < 0 : negative only
    #   * if lev0 * lev1 < 0 : both positive and negative
    #     such as over -lev0..-lev1, lev1..lev2
    # RETURN VALUE:
    # * [ levels, mjmn ]
    def quasi_log_levels(lev0, lev1, cycle=1)
      raise(ArgumentError, "lev0 is zero (non-zero required)") if lev0 == 0.0
      raise(ArgumentError, "lev1 is zero (non-zero required)") if lev1 == 0.0
      case cycle
      when 1
        cycl_levs = [1.0]
      when 2
        cycl_levs = [1.0, 3.0]
      when 3
        cycl_levs = [1.0, 2.0, 5.0]
      else
        raise(ArgumentError, "cycle must be 1,2,or 3, which is now #{cycle}")
      end

      if lev0 > 0 and lev1 > 0
        positive = true
        negative = false
      elsif  lev0 < 0 and lev1 < 0
        positive = false
        negative = true
      else
        positive = true
        negative = true
      end
      sml, big = [lev0.abs,lev1.abs].sort

      expsml = Math::log10(sml).floor
      expbig = Math::log10(big).ceil

      levels = Array.new
      mjmn = Array.new

      for i in expsml..expbig-1
        for k in 0..cycle-1
          lev = cycl_levs[k] * 10**i
          if lev >= sml && lev <= big
            levels.push( lev )
            mjmn.push( k==0 ? 1 : 0 )
          end
        end
      end
      lev = 10**expbig
      if lev == big
        levels.push( lev )
        mjmn.push( 1 )
      end

      if negative && !positive
        levels = levels.reverse.collect{|x| -x}
        mjmn = mjmn.reverse
      elsif negative && positive
        levels.dup.each{|x| levels.unshift(-x)}
        mjmn.dup.each{|x| mjmn.unshift(x)}
      end

      [ levels, mjmn ]
    end
  end

  ####################################################################
  ####################################################################
  ####################################################################

  module GGraph

    class << self
      ## private methods in the module
      def __shorten_path(str,maxlen)
        return str if str.length <= maxlen
        astr = str.split(/\//)
        while(str.length > maxlen)
          astr.length!=2 ? at = (astr.length)/2 : at = 0
          astr.delete_at( at )
          (a = astr.dup)[at, 0] = '...'    # insert(at,'...') if Ruby>=1.8
          str = a.join('/')
        end
        str
      end
      private :__shorten_path
    end

    module_function

    def gropn_1_if_not_yet
      begin
        DCL.stqwrc
      rescue
        DCL.gropn(1)
      end
    end

    def margin_info(program=nil, data_source=nil, char_height=nil, date=nil,
                    xl=0.0, xr=0.0, yb=nil, yt=0.0)

      program = File.expand_path($0)       if !program
      if date
        program = __shorten_path(program,77) + '  ' + Date.today.to_s
      else
        program = __shorten_path(program,99)
        if date.nil?
          program = program + '  ' + Date.today.to_s if program.length < 77
        end
      end
      if !data_source
        data_source = Dir.pwd
        data_source = '' if data_source == program.sub(/\/[^\/]+$/,'')
      end
      data_source = __shorten_path(data_source,99)
      sz = 1.0/( program.length + data_source.length )
      char_height = [0.008, sz].min        if !char_height
      yb = 2.0 * char_height               if !yb

      DCL.slmgn(xl, xr, yb, yt)
      DCL.slsttl(program,     'b', -1.0, -1.0, char_height, 1)
      DCL.slsttl(data_source, 'b',  1.0, -1.0, char_height, 2)
      nil
    end

    def color_bar(*args)
      DCLExt.color_bar(*args)
    end

    def title(string)
      if string
        if map_trn? || itr_is?(5)
          v = DCL::sgqvpt
          txhgt = DCL.uzpget('rsizec2')     # rsizec2: larger text
          vx = (v[0]+v[1])/2
          vy = v[3] + (0.5 + DCL.uzpget('pad1')) * txhgt
          DCL::sgtxzr(vx , vy, string, txhgt, 0, 0, 3)
        else
          DCL.uxmttl('t',string,0.0)
        end
      end
      nil
    end

    def annotate(str_ary, noff=nil)
      charsize = 0.7 * DCL.uzpget('rsizec1')
      vxmin,vxmax,vymin,vymax = DCL.sgqvpt
      vx = vxmax + 0.01
      vy = vymax - charsize/2
      annotate_at(str_ary,vx,vy,charsize,-1.0,-1.5,noff)
    end

    def annotate_at(str_ary,vx,vy,charsize=nil, align=-1.0, dvyfact=-1.5, noff=nil)
      raise TypeError,"Array expected" if ! str_ary.is_a?(Array)
      charsize = 0.7 * DCL.uzpget('rsizec1') unless(charsize)
      dvy = charsize*dvyfact
      vy += noff*dvy if noff
      str_ary.each{|str|
        DCL::sgtxzr(vx,vy,str,charsize,0,align,1)
        vy += dvy
      }
      nannot = str_ary.length
      nannot += noff if noff
      nannot
    end

    @@fig = Misc::KeywordOptAutoHelp.new(
      ['new_frame',true,      'whether to define a new frame by DCL.grfrm (otherwise, DCL.grfig is called)'],
      ['no_new_fig',false,      'If true, neither DCL.grfrm nor DCL.grfig is called (overrides new_frame) -- Then, you need to call one of them in advance. Convenient to set DCL parameters that are reset by grfrm or grfig.'],
      ['itr',     1,     'coordinate transformation number'],
      ['viewport',[0.2,0.8,0.2,0.8], '[vxmin, vxmax, vymin, vymax]'],
      ['eqdistvpt',false, 'modify viewport to equidistant for x and y (only for itr=1--4)'],
      ['window',  nil, '(for itr<10,>50) [uxmin, uxmax, uymin, uymax]. each element allowd nil (only for itr<5,>50)'],
      ['xreverse','positive:down,units:hPa', '(for itr<10,>50) Assign max value to UXMIN and min value to UXMAX if condition is satisfied (nil:never, true:always, String: when an attibute has the value specified ("key:value,key:value,..")'],
      ['yreverse','positive:down,units:hPa', '(for itr<10,>50) Assign max value to UYMIN and min value to UYMAX if condition is satisfied (nil:never, true:always, String: when an attibute has the value specified ("key:value,key:value,..")'],
      ['round0',     false,     'expand window range to good numbers (effective only to internal window settings)'],
      ['round1',     false,     'expand window range to good numbers (effective even when "window" is explicitly specified)'],
      # for 5<=itr<=7 (Rectangular Curvilinear Coordinates)
      ['similar', nil, '3-element float array for similar transformation in a rectangular curvilinear coordinate, which is fed in DCL:grssim:[simfac,vxoff,vyoff],  where simfac and [vxoff,vyoff] represent scaling factor and origin shift, respectively.'],
      # for 10<=itr<=50 (map projection):
      ['map_axis', nil, '(for all map projections) 3-element float array to be fed in DCL::umscnt: [uxc, uxy, rot], where [uxc, uyc] represents the tangential point (or the pole at top side for cylindrical projections), and rot represents the rotation angle. If nil, internally determined. (units: degrees)'],
      ['map_radius', nil, '(for itr>=20: conical/azimuhal map projections) raidus around the tangential point. (units: degrees)'],
      ['map_fit',nil,'(Only for itr=10(cylindrical) and 11 (Mercator)) true: fit the plot to the data window (overrides map_window and map_axis); false: do not fit (then map_window and map_axis are used); nil: true if itr==10, false if itr==11'],
      ['map_window', [-180,180,-75,75], '(for itr<20: cylindrical map projections) lon-lat window [lon_min, lon_max, lat_min, lat_max ] to draw the map (units: degres)']
    )

    def set_fig(options)
      @@fig.set(options)
    end

    @@next_fig = nil
    def next_fig(options)
      if options.is_a?(Hash)
        @@next_fig = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def map_trn?( fig_yet_to_be_called=false )
      if fig_yet_to_be_called
        itr = ( @@next_fig && @@next_fig['itr'] ) || @@fig['itr']
      else
        itr = DCL.sgqtrn
      end
      case itr
      when 1..9,51..99
        false
      else
        true
      end
    end

    def itr_is?( itr, fig_yet_to_be_called=false )
      if fig_yet_to_be_called
        current_itr = ( @@next_fig && @@next_fig['itr'] ) || @@fig['itr']
      else
        current_itr = DCL.sgqtrn
      end
      current_itr == itr
    end

    def sim_trn?
      itr = DCL.sgqtrn
      case itr
      when 5..7
        true
      else
        false
      end
    end

    def fig(xax=nil, yax=nil, options=nil)

      # xax and yax are needed (i.e. Axis objects) if not map projection

      if @@next_fig
        options = ( options ? @@next_fig.update(options) : @@next_fig )
        @@next_fig = nil
      end
      opts = @@fig.interpret(options)

      if opts['no_new_fig']
        # do nothing
      elsif opts['new_frame']
        DCL.grfrm
      else
        DCL.grfig
      end
      raise "viewport's length must be 4" if opts['viewport'].length != 4
      DCL.grsvpt(*opts['viewport'])

      if opts['window']
        if !opts['window'].is_a?(Array) || opts['window'].length!=4
          raise "Option 'window' must be an Array of length==4"
        end
      end

      itr = opts['itr']
      DCL.grstrn(itr)

      map_fit = ( (itr==10 and opts['map_fit']!=false) or
                  (itr==11 and opts['map_fit']==true)  )

      if ( (1<=itr and itr<=4) or (51<=itr and itr<=99) or map_fit )
        window = opts['window']
        window = ( window ? window.dup : [nil, nil, nil, nil])
        if window.include?(nil)
          raise(ArgumentError, "xax and yax must be provided") if !xax or !yax
          if (xreverse=opts['xreverse']).is_a?(String)
            atts = opts['xreverse'].split(',').collect{|v| v.split(':')}
            xreverse = false
            atts.each{|key,val|
              xreverse = ( xax.get_att(key) == val )
              break if xreverse
            }
          end
          if (yreverse=opts['yreverse']).is_a?(String)
            atts = opts['yreverse'].split(',').collect{|v| v.split(':')}
            yreverse = false
            atts.each{|key,val|
              yreverse = ( yax.get_att(key) == val )
              break if yreverse
            }
          end
          if xreverse
            xrange = [ xax.max, xax.min ]
          else
            xrange = [ xax.min, xax.max ]
          end
          if yreverse
            yrange = [ yax.max, yax.min ]
          else
            yrange = [ yax.min, yax.max ]
          end
          [ xrange, yrange ].each do |range|
            r0 = range[0]
            r1 = range[1]
            if r0 == r1
              if r0.nil?
                raise("Cannot set a window. Maybe plotting all-missing data?")
              end
              # if the max and min of the range is the same, shift them a bit
              range[0] = DCL.rgnlt(r0)
              range[1] = DCL.rgngt(r0)
            end
          end
          default_window=[xrange[0], xrange[1], yrange[0], yrange[1]]
          default_window = __round_window(default_window) if opts['round0']
          if window.nitems == 0     # if all elements is nil
            window = default_window
          else
            window.each_index do |i|
              window[i] = default_window[i] if window[i] == nil
            end
          end
          window = __round_window(window) if opts['round1']
        end
      end

      case itr
      when 1..4,51..99
        # all but for map projections and curvilinear coordinates
        DCL.grswnd(*window)
        if itr <= 4 and opts['eqdistvpt']
          # modify viewport to equidistant
          vx1,vx2,vy1,vy2 = opts['viewport']
          wx1,wx2,wy1,wy2 = window
          vxw = (vx2-vx1).abs
          vyw = (vy2-vy1).abs
          wxw = (wx2-wx1).abs
          wyw = (wy2-wy1).abs
          if ( [vxw,vyw,wxw,wyw].min > 0 )
            rx = wxw / vxw
            ry = wyw / vyw
            if rx > ry
              rc = ry/rx
              vym = (vy1+vy2)/2.0
              vy1 = vym - rc*vyw/2.0
              vy2 = vym + rc*vyw/2.0
            elsif rx < ry
              rc = rx/ry
              vxm = (vx1+vx2)/2.0
              vx1 = vxm - rc*vxw/2.0
              vx2 = vxm + rc*vxw/2.0
            end
            DCL.grsvpt(vx1,vx2,vy1,vy2)
          end
        end
      when 5,6
          if opts['similar']
            similar=opts['similar']
            DCL.grssim(*similar)
          elsif opts['window']
            if defined?(DCL::DCLVERSION) && DCL::DCLVERSION >= '5.3'
              DCL.sgscwd(*opts['window'])
            else
              raise "You need DCL 5.3 or later to use the 'window' parameter in this transform (#{itr}). Use 'similar' instead."
            end
          else
            case itr
            when 5
              vxmin,vxmax,vymin,vymax=DCL.sgqvpt
              raise(ArgumentError, "xax must be provided") if !xax
              simfac = (vymax-vymin)/(xax.max*2)    # only xax is used
              similar = [simfac,0.0,0.0]
              DCL.grssim(*similar)
            else
              raise NotImplementedError, "Sorry, automatic window setting is yet to be available for the transform #{itr}. Please specify the 'similar' or 'window' parameter"
            end
          end

      when 10..15
        if !map_fit
          map_axis = opts['map_axis'] || [180.0, 0.0, 0.0]
          DCL::umscnt( *map_axis )
          map_window = opts['map_window']
          raise "map_window's length must be 4" if map_window.length != 4
          map_lat_range = [ map_window[2], map_window[3] ]
          if map_lat_range.is_a?(Range)
            map_lat_range = [map_lat_range.first, map_lat_range.end]
          end
          case ( map_axis[2] - map_axis[1] ) % 360
          when 0
            tyrange = map_lat_range
          when 180
            tyrange = [ -map_lat_range[1], -map_lat_range[0] ]
          else
            tyrange = [ -75, 75 ]      # latange is ignored
          end
          DCL::grstxy(map_window[0], map_window[1], tyrange[0], tyrange[1])
        else
          lon_cent =( window[0] + window[1] ) / 2.0
          dlon2 = ( window[1] - window[0] ) / 2.0
          map_axis = [ lon_cent, 0.0, 0.0 ]
          DCL::sgswnd(*window)
          DCL::umscnt( *map_axis )
          DCL::grstxy( -dlon2, dlon2, window[2], window[3] )
        end
        sv = DCL.umpget('lglobe')
        DCL.umpset('lglobe', true)
        DCL::umpfit
      when 20..33
        map_axis = opts['map_axis'] || [180.0, 90.0, 0.0]
        map_radius = opts['map_radius'] || 70.0
        DCL::umscnt( *map_axis )
        case itr
        when 31
          v = opts['viewport']
          vptsize = [ v[1]-v[0], v[3]-v[2] ].min
          DCL::grssim( vptsize*0.25/Math::tan(0.5*Math::PI*map_radius/180.0), 0.0, 0.0 )
        when 22
          v = opts['viewport']
          vptsize = [ v[1]-v[0], v[3]-v[2] ].min
          DCL::grssim( vptsize*0.35*(90.0/map_radius), 0.0, 0.0 )
          DCL::grstxy(-180.0, 180.0, 90.0-map_radius, 90.0)
        else
          DCL::grstxy(-180.0, 180.0, 90.0-map_radius, 90.0)
        end
        sv = DCL.umpget('lglobe')
        DCL.umpset('lglobe', true)
        DCL::umpfit
        DCL.umpset('lglobe', sv)
      else
        raise "unsupported transformation number: #{itr}"
      end

      DCL.grstrf
      DCL.umpset('lglobe', sv)
      nil
    end

    def __good_range(x0,x1)
      x0 = x0.to_f
      x1 = x1.to_f
      xw = (x1-x0).abs
      e10, lx  = (Math::log10(xw)).divmod(1.0)
      ef = 5.0 * 10**(-e10)
      [(x0*ef).floor/ef,(x1*ef).ceil/ef]
    end
    private :__good_range
    def __round_window(window)
      x0,x1 = __good_range(window[0],window[1])
      y0,y1 = __good_range(window[2],window[3])
      [ x0, x1, y0, y1 ]
    end
    private :__round_window

    @@axes = Misc::KeywordOptAutoHelp.new(
      ['xside',  'tb',  'Where to draw xaxes (combination of t, b and u)'],
      ['yside',  'lr',  'Where to draw yaxes (combination of l, r and u)'],
      ['xtitle',  nil,  'Title of x axis (if nil, internally determined)'],
      ['ytitle',  nil,  'Title of y axis (if nil, internally determined)'],
      ['xunits',  nil,  'Units of x axis (if nil, internally determined)'],
      ['yunits',  nil,  'Units of y axis (if nil, internally determined)'],
      ['xtickint',  nil,
            'Interval of x axis tickmark (if nil, internally determined)'],
      ['ytickint',  nil,
            'Interval of y axis tickmark (if nil, internally determined)'],
      ['xlabelint',  nil,
               'Interval of x axis label (if nil, internally determined)'],
      ['ylabelint',  nil,
               'Interval of y axis label (if nil, internally determined)'],
      ['xmaplabel',  false,
               'If "lon"("lat"), use DCLExt::lon_ax(DCLExt::lat_ax) to draw xaxes; otherwise, DCL::usxaxs is used.'],
      ['ymaplabel',  false,
               'If "lon"("lat"), use DCLExt::lon_ax(DCLExt::lat_ax) to draw yaxes; otherwise, DCL::usyaxs is used.'],
      ['time_ax',  nil,  'Type of calendar-type time axis: nil (=> auto slection), false (do not use the time axis even if the units of the axis is a time one with since field), "h" (=> like nil, but always use the hour-resolving datetime_ax method in dclext_datetime_ax.rb), or "ymd" (=> like "h" but for y-m-d type using DCL.uc[xy]acl)']
    )
    def set_axes(options)
      @@axes.set(options)
    end

    @@next_axes = nil
    def next_axes(options)
      if options.is_a?(Hash)
        @@next_axes = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    # axtype: nil (-->auto), 'h' (to resolve hours), or 'ymd'
    def __calendar_ax(axtype, xax, side, sunits, ttl, \
                     tickint=nil, labelint=nil)
      window = DCL.sgqwnd
      viewport = DCL.sgqvpt
      /(.*) *since *(.*)/ =~ sunits
      if (!$1 or !$2)
        raise("Units mismatch. Requires time units that includes 'since'")
      end
      tun = Units[$1]
      dayun = Units['days']
      since = DateTime.parse($2)
      if xax
        t0 = window[0]
        t1 = window[1]
      else
        t0 = window[2]
        t1 = window[3]
      end
      tstr = since + tun.convert( t0, dayun )
      jd0 = tstr.strftime('%Y%m%d').to_i
      tlen = tun.convert( t1-t0, dayun )
      if !axtype
        if tlen < 5
          axtype = 'h'
        else
          axtype = 'ymd'
        end
      end

      if xax
        DCL.grswnd(0.0, tlen, window[2], window[3] )
        DCL.grstrf
        if axtype == 'h'
          opts = {'cside'=>side}
          opts['dtick1'] = tickint if tickint
          opts['dtick2'] = labelint if labelint
          DCLExt.datetime_ax(tstr, tstr+tlen, opts )
        else
          DCL.ucxacl(side,jd0,tlen)
        end
        DCL.grswnd(*window)
        DCL.grstrf
      else
        DCL.grswnd(window[0], window[1], 0.0, tlen)
        DCL.grstrf
        if axtype == 'h'
          opts = {'yax'=>true, 'cside'=>side}
          opts['dtick1'] = tickint if tickint
          opts['dtick2'] = labelint if labelint
          DCLExt.datetime_ax(tstr, tstr+tlen, opts )
        else
          DCL.ucyacl(side,jd0,tlen)
        end
        DCL.grswnd(*window)
        DCL.grstrf
      end
    end
    private :__calendar_ax

    def axes(xax=nil, yax=nil, options=nil)
      if @@next_axes
        options = ( options ? @@next_axes.update(options) : @@next_axes )
        @@next_axes = nil
      end
      opts = @@axes.interpret(options)
      if opts['xside'].length > 0
        xai = _get_axinfo(xax)
        if opts['xmaplabel'] == "lon"
          opts['xside'].split('').each{|s|     # scan('.') also works
            DCLExt.lon_ax('cside'=>s, 'dtick1'=>opts['xtickint'], 'dtick2'=>opts['xlabelint'])
          }
          DCL.uxsttl('b', (opts['xtitle'] || xai['title']), 0.0)
        elsif opts['xmaplabel'] == "lat"
          opts['xside'].split('').each{|s|     # scan('.') also works
            DCLExt.lat_ax('xax'=>true, 'cside'=>s, 'dtick1'=>opts['xtickint'], 'dtick2'=>opts['xlabelint'])
          }
          DCL.uxsttl('b', (opts['xtitle'] || xai['title']), 0.0)
        else
          sunits = opts['xunits'] || xai['units']
          units = Units[sunits]
          if opts['time_ax'] != false && \
             /since/ =~ sunits && units =~ Units['days since 0001-01-01']
            opts['xside'].split('').each do |s|   # scan('.') also works
              ttl = opts['xtitle'] || xai['title']
              __calendar_ax(opts['time_ax'], true, s, sunits, ttl,
                	   opts['xtickint'], opts['xlabelint'])
            end
          else
            DCL.uscset('cxttl', (opts['xtitle'] || xai['title']) )
            DCL.uscset('cxunit', sunits)
            DCL.uspset('dxt', opts['xtickint'])  if(opts['xtickint'])
            DCL.uspset('dxl', opts['xlabelint']) if(opts['xlabelint'])
            opts['xside'].split('').each{|s|     # scan('.') also works
              DCL.usxaxs(s)
            }
          end
        end
      end
      if opts['yside'].length > 0
        yai = _get_axinfo(yax)
        if opts['ymaplabel'] == "lon"
          opts['yside'].split('').each{|s|   # scan('.') also works
            DCLExt.lon_ax('yax'=>true, 'cside'=>s, 'dtick1'=>opts['ytickint'], 'dtick2'=>opts['ylabelint'])
          }
          DCL.uysttl('l', (opts['ytitle'] || yai['title']), 0.0)
        elsif opts['ymaplabel'] == "lat"
          opts['yside'].split('').each{|s|   # scan('.') also works
            DCLExt.lat_ax('cside'=>s, 'dtick1'=>opts['ytickint'], 'dtick2'=>opts['ylabelint'])
          }
          DCL.uysttl('l', (opts['ytitle'] || yai['title']), 0.0)
        else
          sunits=(opts['yunits'] || yai['units'])
          units = Units[sunits]
          if opts['time_ax'] != false && \
             /since/ =~ sunits && units =~ Units['days since 0001-01-01']
            opts['yside'].split('').each do |s|   # scan('.') also works
              ttl = opts['ytitle'] || yai['title']
              __calendar_ax(opts['time_ax'], false, s, sunits, ttl,
                	   opts['ytickint'], opts['ylabelint'])
            end
          else
            DCL.uscset('cyttl', (opts['ytitle'] || yai['title']) )
            DCL.uscset('cyunit', sunits )
            DCL.uspset('dyt', opts['ytickint'])  if(opts['ytickint'])
            DCL.uspset('dyl', opts['ylabelint']) if(opts['ylabelint'])
            opts['yside'].split('').each{|s|   # scan('.') also works
              DCL.usyaxs(s)
              if s=='l' && sunits && sunits != ''
                DCL.uzpset('roffxt', DCL.uzpget('rsizec1')*1.5 )
              end
            }
          end
        end
      end
      nil
    end

    def _get_axinfo(vary)
      if vary.nil?
        hash = {
                'title'=>'',
                'units'=>''
               }
      else
        raise "Not 1D" if vary.rank!=1
        hash = {
                'title'=>(vary.get_att('long_name') || vary.name), #.gsub('_','' )
                'units'=>(vary.get_att('units') || '')             #.gsub('_',' ')
               }
      end
      hash
    end

    def polar_coordinate_boundaries(xax=nil,yax=nil)

      slln=DCL.sgpget('LLNINT') ; slgc=DCL.sgpget('LGCINT')
      DCL.sgpset('LLNINT',true) ; DCL.sgpset('LGCINT',true)

      xmin=xax.min ; xmax=xax.max ; ymin=yax.min ; ymax=yax.max
      azimuth_len = ymax-ymin
      azimuth_len = azimuth_len.val if azimuth_len.is_a?(UNumeric)
      unless( (azimuth_len - 360.0).abs < 1e-2 )
        # not a full circle
        DCL.sgplzu([xmin,xmax],[ymin,ymin],1,5)
        DCL.sgplzu([xmin,xmax],[ymax,ymax],1,5)
      end

      DCL.sgplzu([xmin,xmin],[ymin,ymax],1,5)
      DCL.sgplzu([xmax,xmax],[ymin,ymax],1,5)

      DCL.sgpset('LLNINT',slln) ; DCL.sgpset('LGCINT',slgc)
      nil
    end

    @@map = Misc::KeywordOptAutoHelp.new(
      ['lim',          true,  'draw map lim (t or f)'],
      ['grid',         true,  'draw map grid (t or f)'],
      ['vpt_boundary', false,  'draw viewport boundaries (f, t or 1,2,3.., representing the line width)'],
      ['wwd_boundary', false,  'draw worksation window boundaries (f, t or 1,2,3.., representing the line width)'],
      ['fill',  false,  'fill the map if coast_world or coast_japan is true (t or f)'],
      ['coast_world',  false,  'draw world coast lines (t or f)'],
      ['border_world', false,  'draw nation borders (t or f)'],
      ['plate_world',  false,  'draw plate boundaries (t or f)'],
      ['state_usa',  false,    'draw state boundaries of US (t or f)'],
      ['coast_japan',  false,  'draw japanese coast lines (t or f)'],
      ['pref_japan',   false,  'draw japanese prefecture boundaries (t or f)'],
      ['dgridmj', nil, 'the interval between the major lines of latitudes and longitudes. If nil, internally determined. (units: degrees) (this is a UMPACK parameter, which is nullified when uminit or grfrm is called)'],
      ['dgridmn', nil, 'the interval between the minor lines of latitudes and longitudes. If nil, internally determined. (units: degrees) (this is a UMPACK parameter, which is nullified when uminit or grfrm is called)']
    )

    def set_map(options)
      @@map.set(options)
    end

    @@next_map = nil
    def next_map(options)
      if options.is_a?(Hash)
        @@next_map = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def map(options=nil)
      if @@next_map
        options = ( options ? @@next_map.update(options) : @@next_map )
        @@next_map = nil
      end
      opts = @@map.interpret(options)
      DCL.umplim if opts['lim']
      DCL.umpset('dgridmj',opts['dgridmj']) if opts['dgridmj']
      DCL.umpset('dgridmn',opts['dgridmn']) if opts['dgridmn']
      DCL.umpgrd if opts['grid']
      if opts['vpt_boundary']
        if opts['vpt_boundary'].is_a?(Integer)
          idx = opts['vpt_boundary']
        else
          idx = 1
        end
        DCL.slpvpr( idx )
      end
      if opts['wwd_boundary']
        if opts['wwd_boundary'].is_a?(Integer)
          idx = opts['wwd_boundary']
        else
          idx = 1
        end
        DCL.slpwwr( idx )
      end
      DCL.umpmap('coast_world') if opts['coast_world']
      DCL.umpmap('coast_japan') if opts['coast_japan']
      if opts['fill']
        DCL.umfmap('coast_world') if opts['coast_world']
        DCL.umfmap('coast_japan') if opts['coast_japan']
      end
      DCL.umpmap('border_world') if opts['border_world']
      DCL.umpmap('plate_world') if opts['plate_world']
      DCL.umpmap('state_usa') if opts['state_usa']
      DCL.umpmap('pref_japan') if opts['pref_japan']
      nil
    end

    def line(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if ! defined?(@@line_options)
        @@line_options = Misc::KeywordOptAutoHelp.new(
          ['title', nil, 'Title of the figure(if nil, internally determined)'],
          ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
          ['exchange', false, 'whether to exchange x and y axes'],
          ['index', 1, 'line/mark index'],
          ['type', 1, 'line type'],
          ['label', nil, 'if a String is given, it is shown as the label'],
          ['max', nil, 'maximam data value'],
          ['min', nil, 'minimam data value'],
          ['legend', nil, 'legend to annotate the line type and index. nil (defalut -- do not show); a String as the legend; true to use the name of the GPhys as the legend'],
          ['legend_vx', nil, '(effective if legend) viewport x values of the lhs of the legend line (positive float); or nil for automatic settting (shown to the right of vpt); or move it to the left relatively (negtive float)'],
          ['legend_dx', nil, '(effective if legend) length of the legend line'],
          ['legend_vy', nil, '(effective if legend) viewport y value of the legend (Float; or nil for automatic settting)'],
          ['legend_size', nil, '(effective if legend) character size of the legend'],
          ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.']
        )
      end
      opts = @@line_options.interpret(options)
      gp = gphys.first1D
      window = ( @@next_fig['window'] if @@next_fig ) || @@fig['window']
      window = ( window ? window.dup : [nil, nil, nil, nil])
      max = opts['max']; min = opts['min']
      if !opts['exchange']
        x = gp.coord(0)
        y = gp.data
        window[2] = min if min
        window[3] = max if max
      else
        y = gp.coord(0)
        x = gp.data
        window[0] = min if min
        window[1] = max if max
      end
      if newframe
        fig(x, y, {'window'=>window})
        axes_or_map_and_ttl(gp, opts, x, y)
      end
      if opts['label']
        lcharbk = DCL.sgpget('lchar')
        DCL.sgpset('lchar',true)
        DCL.sgsplc(opts['label'])
      end
      DCL.uulinz(x.val, y.val, opts['type'], opts['index'])
      DCL.sgpset('lchar',lcharbk) if opts['label']

      legend = opts['legend']
      if legend
        legend = gp.name if legend==true
        DCLExt::legend(legend,opts['type'],opts['index'],true,
                       opts['legend_size'],opts['legend_vx'],opts['legend_dx'],
                       opts['legend_vy'],newframe)
      end
      nil
    end

    def mark(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if ! defined?(@@mark_options)
        @@mark_options = Misc::KeywordOptAutoHelp.new(
          ['title', nil, 'Title of the figure(if nil, internally determined)'],
          ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
          ['exchange', false, 'whether to exchange x and y axes'],
          ['index', 1, 'mark index'],
          ['type', 2, 'mark type'],
          ['size', 0.01, 'marks size'],
          ['max', nil, 'maximam data value'],
          ['min', nil, 'minimam data value'],
          ['legend', nil, 'legend to annotate the mark type, index, and size. nil (defalut -- do not to show); a String as the legend; true to use the name of the GPhys as the legend'],
          ['legend_vx', nil, '(effective if legend) viewport x values of the lhs of the legend line (positive float); or nil for automatic settting (shown to the right of vpt); or move it to the left relatively (negtive float)'],
          ['legend_vy', nil, '(effective if legend) viewport y value of the legend (Float; or nil for automatic settting)'],
          ['legend_size', nil, '(effective if legend) character size of the legend'],
          ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.']
        )
      end
      opts = @@mark_options.interpret(options)
      gp = gphys.first1D
      window = ( @@next_fig['window'] if @@next_fig ) || @@fig['window']
      window = ( window ? window.dup : [nil, nil, nil, nil])
      max = opts['max']; min = opts['min']
      if !opts['exchange']
        x = gp.coord(0)
        y = gp.data
        window[2] = min if min
        window[3] = max if max
      else
        y = gp.coord(0)
        x = gp.data
        window[0] = min if min
        window[1] = max if max
      end
      if newframe
        fig(x, y, {'window'=>window})
        axes_or_map_and_ttl(gp, opts, x, y)
      end
      DCL.uumrkz(x.val, y.val, opts['type'], opts['index'], opts['size'])

      legend = opts['legend']
      if legend
        legend = gp.name if legend==true
        DCLExt::legend(legend,opts['type'],opts['index'],false,
                       opts['legend_size'],opts['legend_vx'],nil,
                       opts['legend_vy'],newframe,opts['size'])
      end
      nil
    end

    @@linear_contour_options =  Misc::KeywordOptAutoHelp.new(
      ['min',      nil,       'minimum contour level'],
      ['max',      nil,       'maximum contour level'],
      ['nlev',     nil,       'number of levels'],
      ['interval', nil,       'contour interval'],
      ['nozero',   nil,       'delete zero contour'],
      ['coloring', false,     'set color contours with ud_coloring'],
      ['clr_min',  13,        '(if coloring) minimum color number for the minimum data values'],
      ['clr_max',  99,       '(if coloring) maximum color number for the maximum data values']
    )
    def set_linear_contour_options(options)
      @@linear_contour_options.set(options)
    end
    @@next_linear_contour_options = nil
    def next_linear_contour_options(options)
      if options.is_a?(Hash)
        @@next_linear_contour_options = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def tone_and_contour(gphys, newframe=true, options=nil)
      options ? topt=@@contour_options.select_existent(options) : topt=nil
      options ? copt=@@tone_options.select_existent(options) : copt=nil
      tone(gphys, newframe, topt)
      contour(gphys, false, copt)
    end

    @@contour_levels =  Misc::KeywordOptAutoHelp.new(
      ['log',   nil,   'approximately log-scaled levels (by using DCLExt::quasi_log_levels)'],
      ['log_cycle',  3,   '(if log) number of levels in one-order (1 or 2 or 3)'],
      ['levels',   nil,   'contour levels (Array/NArray of Numeric)'],
      ['index',    nil,   '(if levels) line index(es) (Array/NArray of integers, Integer, or nil)'],
      ['line_type',nil,   '(if levels) line type(s) (Array/NArray of integers, Integer, or nil)'],
      ['label',    nil,   '(if levels) contour label(s) (Array/NArray of String, String, true, false, nil). nil is recommended.'],
      ['label_height',nil,'(if levels) label height(s) (Array/NArray of Numeric, Numeric, or nil). nil is recommended.']
    )
    @@set_contour_levels=false
    def set_contour_levels(options)
      opts = @@contour_levels.interpret(options)
      _set_contour_levels_(opts)
    end
    def _set_contour_levels_(opts)
      raise ArgumentError, "'levels' must be explicitly set" if !opts['levels']
      DCLExt.ud_set_contour(opts['levels'],opts['index'],opts['line_type'],
                  opts['label'],opts['label_height'])
      @@set_contour_levels=true
      nil
    end

    def clear_contour_levels
      @@set_contour_levels=false
      DCL.udiclv   # this may not be needed
      nil
    end

    def set_contour(options)
      @@contour_options.set(options)
    end

    @@next_contour = nil
    def next_contour(options)
      if options.is_a?(Hash)
        @@next_contour = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    @@contour_options = Misc::KeywordOptAutoHelp.new(
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['transpose', false, 'if true, exchange x and y axes'],
      ['exchange', false, 'same as the option transpose'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['keep', false, 'Use the contour levels used previously'],
      @@linear_contour_options,
      @@contour_levels
    )

    def axes_or_map_and_ttl(gp, opts, xax, yax)
      ttl = (opts['title'] || gp.get_att('long_name'))
      if map_trn?
        map
        if opts['map_axes'] && itr_is?(10)
          vpt = DCL.sgqvpt
          wnd = DCL.sgqwnd
          if wnd.include?(DCL.glrget('rundef'))
            map_fit = false
            wnd = DCL.sgqtxy
            cnt = DCL.umqcnt
          else
            map_fit = true
          end
          vrat = ( (vpt[3]-vpt[2]) / (vpt[1]-vpt[0]) ).abs
          wrat = ( (wnd[3]-wnd[2]) / (wnd[1]-wnd[0]) ).abs
          if wrat < vrat
            vyoff = (vpt[3]+vpt[2])/2
            dvy2 =  (vpt[1]-vpt[0])*wrat/2
            vpt[2] = vyoff - dvy2
            vpt[3] = vyoff + dvy2
          else
            vxoff = (vpt[1]+vpt[0])/2
            dvx2 =  (vpt[3]-vpt[2])/wrat/2
            vpt[0] = vxoff - dvx2
            vpt[1] = vxoff + dvx2
          end
          trn = DCL.sgqtrn
          if map_fit
            fig(xax,yax, {'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt})
            axes(xax, yax)
            title( ttl )
            DCL.sgstrn(trn)
          else
            xax_map = xax[0..1].copy
            xax_map[0] = cnt[0] + wnd[0]
            xax_map[1] = cnt[0] + wnd[1]
            yax_map = yax[0..1].copy
            yax_map[0] = wnd[2]
            yax_map[1] = wnd[3]
            fig(xax_map,yax_map,{'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt})
            axes(xax_map,yax_map)
            title( ttl )
            fig(xax_map,yax_map,{'itr'=>trn, 'new_frame'=>false, 'viewport'=>vpt, 'map_fit'=>false, 'map_axis'=>cnt, 'map_window'=>wnd})
          end
        else
          title( ttl )
        end
      elsif itr_is?(5)
        polar_coordinate_boundaries(xax,yax)
        title( ttl )
      else
        axes(xax, yax)
        title( ttl )
      end
      annotate(gp.lost_axes) if opts['annotate']
    end

    def contour(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if @@next_contour
        options = ( options ? @@next_contour.update(options) : @@next_contour )
        @@next_contour = nil
      end
      if @@next_linear_contour_options
        options = ( options ? @@next_linear_contour_options.update(options) :
                              @@next_linear_contour_options )
        @@next_linear_contour_options = nil
      end
      opts = @@contour_options.interpret(options)
      gp = gphys.first2D
      gp = gp.transpose(1,0) if opts['transpose'] || opts['exchange']
      xax = gp.coord(0)
      yax = gp.coord(1)
      if map_trn?(newframe)
        # /// convert to the anti-clockwise coordinate in case for map filling
        #     (Because of a bug in UMFMAP in DCL 5.3)  -->
        if ( (xax[-1].val-xax[0].val)*(yax[-1].val-yax[0].val) < 0 )
          gp = gp.copy[true,-1..0]
          yax = gp.coord(1)
        end
        # <-- ///
        gp = gp.cyclic_ext(0, 360.0)  #cyclic extention with lon if appropriate
        xax = gp.coord(0)
      elsif itr_is?(5, newframe)
        gp = gp.cyclic_ext(1, 360.0)  # cyclic extention along azimuth
        yax = gp.coord(1)
      end
      if newframe
        fig(xax, yax)
      end
      if newframe
        axes_or_map_and_ttl(gp,opts, xax, yax)
      end
      if !opts['keep'] or DCL.udqcln==0
        if !opts['levels'] && opts['log']
          levels, mjmn = DCLExt.quasi_log_levels_z(gp.data.val, opts['nlev'],
                                  opts['max'], opts['min'], opts['log_cycle'])
          opts['levels'] = levels
          opts['index'] = NArray.to_na(mjmn)*2 + 1 if !opts['index']
          opts['label'] = true if opts['label'].nil?
        end
        if (opts['levels'])
          backup = @@set_contour_levels
          _set_contour_levels_(opts)
          @@set_contour_levels = backup
        elsif !@@set_contour_levels
          DCLExt.ud_set_linear_levs(gp.data.val, opts)
        end
      end
      saved_udparams = nil
      if DCL.udqcln >= 3
        lv1, = DCL.udqclv(1)
        lv2, = DCL.udqclv(2)
        lv3, = DCL.udqclv(3)
        if lv2-lv1 != lv3-lv2
          saved_udparams = DCLExt.ud_set_params({'lmsg'=>false})
        end
      end
      DCL.uwsgxa(xax.val)
      DCL.uwsgya(yax.val)
      DCL.udcntz(gp.data.val)
      DCLExt.ud_set_params(saved_udparams) if saved_udparams
      nil
    end

    @@linear_tone_options =  Misc::KeywordOptAutoHelp.new(
      ['min',      nil,       'minimum tone level'],
      ['max',      nil,       'maximum tone level'],
      ['nlev',     nil,       'number of levels'],
      ['interval', nil,       'contour interval']
    )
    def set_linear_tone_options(options)
      @@linear_tone_options.set(options)
    end
    @@next_linear_tone_options = nil
    def next_linear_tone_options(options)
      if options.is_a?(Hash)
        @@next_linear_tone_options = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    @@tone_levels =  Misc::KeywordOptAutoHelp.new(
      ['log',   nil,   'approximately log-scaled levels (by using DCLExt::quasi_log_levels)'],
      ['log_cycle',  3,   '(if log) number of levels in one-order (1 or 2 or 3)'],
      ['levels',   nil,   'tone levels  (Array/NArray of Numeric). Works together with patterns'],
      ['patterns', nil,   'tone patters (Array/NArray of Numeric). Works together with levels']
    )
    @@set_tone_levels=false
    def set_tone_levels(options)
      opts = @@tone_levels.interpret(options)
      _set_tone_levels_(opts)
    end
    def _set_tone_levels_(opts)
      if !opts['levels'] && !opts['patterns']
      end
      if opts['levels']
        levels = opts['levels']
      else
        raise ArgumentError,"'levels' must be explicitly set"
      end
      if opts['patterns']
        patterns = opts['patterns']
      else
        nlev = levels.length - 1
        itpat = DCL.ueiget('itpat')
        iclr1 = DCL.ueiget('icolor1')
        iclr2 = DCL.ueiget('icolor2')
        patterns = (0...nlev).collect{|i|
          (((iclr2-iclr1)/(nlev-1.0)*i+iclr1).round) * 1000 + itpat
        }
      end
      DCLExt.ue_set_tone(levels,patterns)
      @@set_tone_levels=true
      nil
    end
    def clear_tone_levels
      @@set_tone_levels=false
      nil
    end

    def set_tone(options)
      @@tone_options.set(options)
    end

    @@next_tone = nil
    def next_tone(options)
      if options.is_a?(Hash)
        @@next_tone = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    @@tone_options = Misc::KeywordOptAutoHelp.new(
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['ltone', true, 'Same as udpack parameter ltone'],
      ['tonf', false, 'Use DCL.uetonf instead of DCL.uetone'],
      ['tonc', false, 'Use DCL.uetonc instead of DCL.uetone'],
      ['clr_min', nil,  'if an integer (in 10..99) is specified, used as the color number for the minimum data values. (the same can be done by setting the uepack parameter "icolor1")'],
      ['clr_max', nil,  'if an integer (in 10..99) is specified, used as the color number for the maximum data values. (the same can be done by setting the uepack parameter "icolor2")'],
      ['transpose', false, 'if true, exchange x and y axes'],
      ['exchange', false, 'same as the option transpose'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['keep', false, 'Use the tone levels and patterns used previously'],
      @@linear_tone_options,
      @@tone_levels
    )

    def tone(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if @@next_tone
        options = ( options ? @@next_tone.update(options) : @@next_tone )
        @@next_tone = nil
      end
      if @@next_linear_tone_options
        options = ( options ? @@next_linear_tone_options.update(options) :
                              @@next_linear_tone_options )
        @@next_linear_tone_options = nil
      end
      opts = @@tone_options.interpret(options)

      if opts['clr_min']
        icolor1_bak = DCL.uepget('icolor1')
        DCL.uepset('icolor1', opts['clr_min'])
      end
      if opts['clr_max']
        icolor2_bak = DCL.uepget('icolor2')
        DCL.uepset('icolor2', opts['clr_max'])
      end
      gp = gphys.first2D
      gp = gp.transpose(1,0) if opts['transpose'] || opts['exchange']
      xax = gp.coord(0)
      yax = gp.coord(1)
      if map_trn?(newframe)
        # /// convert to the anti-clockwise coordinate in case for map filling
        #     (Because of a bug in UMFMAP in DCL 5.3)  -->
        if ( (xax[-1].val-xax[0].val)*(yax[-1].val-yax[0].val) < 0 )
          gp = gp.copy[true,-1..0]
          yax = gp.coord(1)
        end
        # <-- ///
        gp = gp.cyclic_ext(0, 360.0)  #cyclic extention with lon if appropriate
        xax = gp.coord(0)
      elsif itr_is?(5, newframe)             # polar coordinate
        gp = gp.cyclic_ext(1, 360.0)  # cyclic extention along azimuth
        yax = gp.coord(1)
      end
      if newframe
        fig(xax, yax)
      end
      DCL.uwsgxa(xax.val)
      DCL.uwsgya(yax.val)
      if !opts['keep'] or DCL.ueqntl==0
        if !opts['levels'] && opts['log']
          levels, = DCLExt.quasi_log_levels_z(gp.data.val, opts['nlev'],
                                  opts['max'], opts['min'], opts['log_cycle'])
          rmiss = DCL.glrget('rmiss')
          levels.unshift(rmiss) if !opts['max'] && levels[0]<0
          levels.push(rmiss)    if !opts['max'] && levels[-1]>0
          opts['levels'] = levels
        end
        if opts['levels']
          backup = @@set_tone_levels
          _set_tone_levels_(opts)
          @@set_tone_levels = backup
        elsif opts['patterns']
          raise "option 'patterns' is not effective unless 'levels' is specified"
        elsif !@@set_tone_levels && opts['ltone']
          DCL.ueitlv
          DCLExt.ue_set_linear_levs(gp.data.val, opts)
        else
          DCL.ueitlv if !@@set_tone_levels
        end
      end

      if opts['tonf'] && opts['ltone']
        DCL.uetonf(gp.data.val)
      elsif opts['tonc'] && opts['ltone']
        DCL.uetonc(gp.data.val)
      else
        DCL.uetone(gp.data.val)
      end

      if newframe
        axes_or_map_and_ttl(gp,opts, xax, yax)
      end
      DCL.uepset('icolor1', icolor1_bak) if opts['clr_min']
      DCL.uepset('icolor2', icolor2_bak) if opts['clr_max']
      nil
    end

    # < vector >

    def set_unit_vect_options(options)
      DCLExt.set_unit_vect_options(options)
    end
    def next_unit_vect_options(options)
      DCLExt.next_unit_vect_options(options)
    end

    @@vxfxratio=nil
    @@vyfyratio=nil

    def vector(fx, fy, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if ! defined?(@@vector_options)
        @@vector_options = Misc::KeywordOptAutoHelp.new(
          ['title', nil, 'Title of the figure(if nil, internally determined)'],
          ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
          ['transpose', false, 'if true, exchange x and y axes'],
          ['exchange', false, 'same as the option transpose'],
          ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
          ['flow_vect', true, 'If true, use DCLExt::flow_vect to draw vectors; otherwise, DCL::ugvect is used.'],
          ['keep', false, 'Use the same vector scaling as in the previous call. -- Currently, works only when "flow_vect" is true'],
          ['xintv', 1, '(Effective only if flow_vect) interval of data sampling in x'],
          ['yintv', 1, '(Effective only if flow_vect) interval of data sampling in y'],
          ['factor', 1.0, '(Effective only if flow_vect) scaling factor to strech/reduce the arrow lengths'],
          ['unit_vect', false, 'Show the unit vector'],
          ['max_unit_vect', false, '(Effective only if flow_vect && unit_vect) If true, use the maximum arrows to scale the unit vector; otherwise, normalize in V coordinate.'],
           ['flow_itr5', false, 'If true, use DclExt::flow_itr5 to draw vectors on 2-dim polar coordinate. Should be set DCL.sgstrn(5)']
        )
      end
      opts = @@vector_options.interpret(options)
      fx = fx.first2D.copy
      fy = fy.first2D.copy
      fx = fx.transpose(1,0) if opts['transpose'] || opts['exchange']
      fy = fy.transpose(1,0) if opts['transpose'] || opts['exchange']
      sh = fx.shape
      if sh != fy.shape
        raise ArgumentError, "shapes of fx and fy do not agree with each other"
      end
      if ((xi=opts['xintv']) >= 2)
        idx = NArray.int((sh[0]/xi.to_f).ceil).indgen!*xi     # [0,xi,2*xi,..]
        fx = fx[idx, true]
        fy = fy[idx, true]
      end
      if ((yi=opts['yintv']) >= 2)
        idx = NArray.int((sh[1]/yi.to_f).ceil).indgen!*yi     # [0,yi,2*yi,..]
        fx = fx[true, idx]
        fy = fy[true, idx]
      end
      xax = fx.coord(0)
      yax = fy.coord(1)
      if map_trn?(newframe)
        # /// convert to the anti-clockwise coordinate in case for map filling
        #     (Because of a bug in UMFMAP in DCL 5.3)  -->
        if ( (xax[-1].val-xax[0].val)*(yax[-1].val-yax[0].val) < 0 )
          fx = fx.copy[true,-1..0]
          fy = fy.copy[true,-1..0]
          yax = fx.coord(1)
        end
        # <-- ///
        fx = fx.cyclic_ext(0, 360.0)  #cyclic extention with lon if appropriate
        fy = fy.cyclic_ext(0, 360.0)  #cyclic extention with lon if appropriate
        xax = fx.coord(0)
      elsif itr_is?(5, newframe)
        fx = fx.cyclic_ext(1, 360.0)  #cyclic extention along azimuth
        fy = fy.cyclic_ext(1, 360.0)  #cyclic extention along azimuth
        yax = fx.coord(1)
      end
      if newframe
        fig(xax, yax)
      end
      if newframe
        if opts['title']
          ttl = opts['title']
        else
          fxnm = fx.data.get_att('long_name') || fx.name
          fynm = fy.data.get_att('long_name') || fy.name
          ttl =   '('+fxnm+','+fynm+')'
        end
        if map_trn?
          map
          if opts['map_axes'] && itr_is?(10)
            vpt = DCL.sgqvpt
            wnd = DCL.sgqwnd
            if wnd.include?(DCL.glrget('rundef'))
              map_fit = false
              wnd = DCL.sgqtxy
              cnt = DCL.umqcnt
            else
              map_fit = true
            end
            vrat = ( (vpt[3]-vpt[2]) / (vpt[1]-vpt[0]) ).abs
            wrat = ( (wnd[3]-wnd[2]) / (wnd[1]-wnd[0]) ).abs
            if wrat < vrat
              vyoff = (vpt[3]+vpt[2])/2
              dvy2 =  (vpt[1]-vpt[0])*wrat/2
              vpt[2] = vyoff - dvy2
              vpt[3] = vyoff + dvy2
            else
              vxoff = (vpt[1]+vpt[0])/2
              dvx2 =  (vpt[3]-vpt[2])/wrat/2
              vpt[0] = vxoff - dvx2
              vpt[1] = vxoff + dvx2
            end
            trn = DCL.sgqtrn
            if map_fit
              fig(xax,yax,{'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt})
              axes(xax, yax)
              title( ttl )
              DCL.sgstrn(trn)
            else
              xax_map = xax[0..1].copy
              xax_map[0] = cnt[0] + wnd[0]
              xax_map[1] = cnt[0] + wnd[1]
              yax_map = yax[0..1].copy
              yax_map[0] = wnd[2]
              yax_map[1] = wnd[3]
              fig(xax_map,yax_map,{'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt})
              axes(xax_map,yax_map)
              title( ttl )
              fig(xax_map,yax_map,{'itr'=>trn, 'new_frame'=>false, 'viewport'=>vpt, 'map_fit'=>false, 'map_axis'=>cnt, 'map_window'=>wnd})
            end
          else
            title( ttl )
          end
        elsif itr_is?(5)
          polar_coordinate_boundaries(xax,yax)
          title(ttl)
        else
          axes(xax, yax)
          title(ttl)
        end
        annotate(fx.lost_axes) if opts['annotate']
      end
      DCL.uwsgxa(xax.val)
      DCL.uwsgya(yax.val)
      if opts['flow_itr5']
        if itr_is?(5)
          DCLExt.flow_itr5( fx, fy, opts['factor'], opts['unit_vect'] )
        else
          raise "flow_itr5 option should use with itr=5."
        end
      elsif opts['flow_vect']
        uninfo = DCLExt.flow_vect(fx.val, fy.val, opts['factor'], 1, 1,
                  (opts['keep']&& @@vxfxratio), (opts['keep'] && @@vyfyratio) )
        @@vxfxratio, @@vyfyratio, = uninfo
        if opts['unit_vect']
          if opts['max_unit_vect']
            DCLExt.unit_vect(*uninfo)
          else
            DCLExt.unit_vect(*uninfo[0..1])
          end
        end
      else
        before=DCLExt.ug_set_params({'lunit'=>true}) if opts['unit_vect']
        DCL.ugvect(fx.val, fy.val)
        DCLExt.ug_set_params(before) if opts['unit_vect']
      end
      nil
    end


  end

end

if $0 == __FILE__
  include NumRu

  # < read command line option if any >

  if ARGV.length == 1
    iws = ARGV[0].to_i
  else
    iws = 1
  end

  #< graphic initialization >

  DCL.gropn(iws)
  DCL.sldiv('y',2,2)
  DCL.sgpset('lcntl', false)
  DCL.sgpset('lfull',true)
  DCL.sgpset('lfprop',true)
  DCL.uzfact(0.9)

  # < show default parameters >
  xdummy = ydummy = nil
  begin
    print "** GGraph::fig options **\n"
    GGraph.fig(xdummy, ydummy, 'help'=>true)
  rescue
  end
  begin
    print "** GGraph::axes options **\n"
    GGraph.axes(xdummy, ydummy, 'help'=>true)
  rescue
  end
  gp_dummy = nil
  begin
    print "** GGraph::line options **\n"
    GGraph.line(gp_dummy,true,'help'=>true)
  rescue
  end
  begin
    print "** GGraph::mark options **\n"
    GGraph.mark(gp_dummy,true,'help'=>true)
  rescue
  end
  begin
    print "** GGraph::contour options **\n"
    GGraph.contour(gp_dummy,true,'help'=>true)
  rescue
  end
  begin
    print "** GGraph::tone options **\n"
    GGraph.tone(gp_dummy,true,'help'=>true)
  rescue
  end
  begin
    print "** GGraph::map options **\n"
    GGraph.map('help'=>true)
  rescue
  end

  #< graphic test / demonstration >

  file = '../../testdata/T.jan.nc'
  gphys = GPhys::NetCDF_IO.open(file, 'T')

  #/ graph 1 /
  GGraph.set_fig('viewport'=>[0.25,0.75,0.12,0.62])
  GGraph.line(gphys.cut(true,35,true).average(0), true)
  #/ graph 2 /
  GGraph.next_fig('itr'=>2)
  GGraph.next_axes('yunits'=>'','xunits'=>'')
  GGraph.line(gphys.cut(true,35,true).average(0), true,
              'exchange'=>true, 'index'=>3, 'title'=>'TEMPERATURE', 'annotate'=>false, 'min'=>-100, 'max'=>20)
  GGraph.mark(gphys.cut(true,35,true).average(0), false,
              'exchange'=>true, 'type'=>3)
  #/ graph 3 /
  GGraph.set_fig('window'=>[nil, 0.1, -70, 20])
  GGraph.mark(gphys.cut(true,35,true).average(0))
  #/ graph 4 /
  GGraph.next_fig('window'=>[nil, nil, -80, 30])
  GGraph.mark(gphys.cut(true,35,true).average(0), true, 'max'=>25)
  GGraph.line(gphys.cut(true,35,true).average(0), false)
  GGraph.set_fig('window'=>nil)
  #/ graph 5 /
  GGraph.contour(gphys)
  #/ graph 6 /
  GGraph.next_fig('itr'=>2)
  GGraph.contour(gphys.cut(135,true,true))
  #/ graph 7 /
  GGraph.set_axes('xunits'=>'', 'yunits'=>'')
  GGraph.contour(gphys,true, 'min'=>0, 'coloring'=>true)
  #/ graph 8 /
  GGraph.set_fig('viewport'=>[0.2,0.8,0.15,0.55])
  GGraph.contour(gphys,true, 'nozero'=>true)
  #/ graph 9 /
  GGraph.contour(gphys,true, 'min'=>10, 'int'=>3)
  DCL.udpset('lmsg',false)
  GGraph.contour(gphys,false, 'max'=>-10, 'int'=>3)
  DCL.udpset('lmsg',true)
  #/ graph 10 /
  GGraph.set_contour_levels('levels'=>[-10,-5,0,5,10],'index'=>[3,1],
                        'line_type'=>2)
  GGraph.contour(gphys)
  GGraph.clear_contour_levels
  #/ graph 11 /
  GGraph.contour(gphys, true, 'levels'=>[0,10,20], 'index'=>3)
  #/ graph 12 /
  GGraph.set_linear_contour_options('nlev'=>24)
  GGraph.next_linear_contour_options('coloring'=>true)
  GGraph.contour(gphys)
  #/ graph 13 /
  GGraph.tone(gphys, true, 'min'=>0)
  sv = DCLExt.ud_set_params('indxmj'=>1,'indxmn'=>1)
  GGraph.contour(gphys, false)
  DCLExt.ud_set_params(sv)
  GGraph.color_bar
  #/ graph 14 /
  GGraph.tone(gphys, true, 'ltone'=>false)
  GGraph.contour(gphys, false)
  #/ graph 15 /
  GGraph.next_fig('itr'=>3)
  GGraph.contour(gphys[1..-1,true,true])
  #/ graph 16 /
  GGraph.tone(gphys, true, 'levels'=>[-20,-10,0,10,20],'patterns'=>[12999,30999,45999,65999,75999,85999])
  GGraph.color_bar('vlength'=>0.25,'landscape'=>true)
  #/ graph 17 /
  GGraph.tone(gphys, true, 'levels'=>[-20,-10,0,10,20],'patterns'=>[30999,45999,65999,75999,85999])
  DCLExt.color_bar('vlength'=>0.25, 'left'=>true)
  #/ graph 18 /
  GGraph.tone(gphys, true, 'levels'=>[-20,-10,0,10,20],'patterns'=>[30999,45999,65999,75999])
  #DCLExt.color_bar('vlength'=>0.25, 'left'=>true)
  DCLExt.color_bar('vlength'=>0.25, 'levels'=>[-20,-10,0,10,20],'patterns'=>[30999,45999,65999,75999])
  #/ graph 19 /
  GGraph.set_fig('viewport'=>[0.3,0.7,0.1,0.6])
  GGraph.contour(gphys,true, 'min'=>0, 'coloring'=>true, 'transpose'=>true)
  GGraph.tone(gphys, false, 'levels'=>[10,20], 'patterns'=>[80999], 'transpose'=>true)
  #/ graph 20 /
  GGraph.set_fig('viewport'=>[0.25,0.75,0.15,0.6])
  GGraph.vector(gphys+10,gphys+10,true,
        {'unit_vect'=>true, 'xintv'=>2, 'yintv'=>2})
  #/ graph 21 /
  GGraph.next_unit_vect_options({'inplace'=>false,'vxuloc'=>0.17,'vyuloc'=>0.07})
  GGraph.vector(gphys+10,gphys-10,true,
        {'unit_vect'=>true, 'max_unit_vect'=>true, 'xintv'=>2, 'yintv'=>2})
  #/ graph 22 /
  GGraph.vector(gphys+10,gphys+10,true,
        {'unit_vect'=>true, 'flow_vect'=>false, 'xintv'=>2, 'yintv'=>2})

  #GGraph.color_bar('help'=>true)
  #/ graph 23 /
  GGraph.set_fig('viewport'=>[0.2,0.8,0.15,0.55])
  GGraph.tone(gphys, true, 'levels'=>[-16,-4,-1,0,1,4,16],'patterns'=>[12999,21999,30999,45999,65999,75999,85999,95999])
  GGraph.color_bar('constwidth'=>true,'vlength'=>0.6,'landscape'=>true,'labelintv'=>1)
  GGraph.color_bar('constwidth'=>true,'vlength'=>0.35,'index'=>1)

  #/ graph 24 /

  GGraph.set_map('coast_world'=>true)

  # -- mercator --
  GGraph.next_fig('itr'=>11)
  GGraph.next_map('fill'=>true)
  GGraph.tone(gphys, true)
  GGraph.color_bar

  #/ graph 25 /

  # -- orthographic --
  GGraph.set_fig('viewport'=>[0.25,0.75,0.1,0.6])
  GGraph.next_fig('itr'=>30,'map_axis'=>[135,60,0],'map_radius'=>60)
  GGraph.tone(gphys, true)
  sv = DCLExt.ud_set_params('indxmj'=>991,'indxmn'=>991)
  GGraph.contour(gphys, false)
  DCLExt.ud_set_params(sv)
  GGraph.color_bar('landscape'=>true) # ,'vlength'=>0.6

  #/ graph 26 /

  # -- polar stero --
  GGraph.next_fig('itr'=>31)
  DCL.sgpset('lclip',true)
  GGraph.next_map('vpt_boundary'=>3,'dgridmj'=>20,'dgridmn'=>10)
  GGraph.tone(gphys, true)
  GGraph.color_bar

  #/ graph 27 /
  # axes for itr=10 (lon-lat projection) -- map_fit=T, map_axes=F (default)
  GGraph.next_fig('itr'=>10)
  GGraph.contour(gphys,true,'title'=>'map_fit=T, map_axes=F (default)')

  #/ graph 28 /
  # axes for itr=10 (lon-lat projection) -- map_fit=T, map_axes=T
  GGraph.next_fig('itr'=>10)
  GGraph.contour(gphys, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T')
  DCL::sgtxzr(0.5,0.64,'Try GPHYSDIR/sample/ggraph_mapfit-axes_dr002687.rb',0.022,0,0.0,22)
  DCL::sgtxzr(0.5,0.6,'for more examples',0.022,0,0.0,22)

  #/ graph 29 /
  # [xy]xmaplabel options for itr=10 -- when it is off (default)
  GGraph.next_fig('itr'=>10)
  GGraph.tone(gphys, true,'map_axes'=>true,'title'=>'default axes')

  #/ graph 30 /
  # [xy]xmaplabel options for itr=10 -- label as 90E, 90W, 30N, 30S etc
  # sample 1
  GGraph.next_fig('itr'=>10)
  GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
  GGraph.tone(gphys, true,'map_axes'=>true,'title'=>'lon/lat axes')
  DCL::sgtxzr(0.5,0.64,'Try GPHYSDIR/sample/ggraph_latlon_labelling_dr002690.rb',0.022,0,0.0,22)
  DCL::sgtxzr(0.5,0.6,'for more options',0.022,0,0.0,22)

  #/ graph 31 /
  # log-level tone/contour (1)
  GGraph.set_fig('itr'=>1,'viewport'=>[0.2,0.85,0.22,0.58])
  GGraph.tone(gphys,true,'log'=>true, 'nlev'=>5, 'log_cycle'=>3 )
  GGraph.contour(gphys,false,'log'=>true, 'nlev'=>5, 'log_cycle'=>3)
  GGraph.color_bar('log'=>true, 'landscape'=>true, 'vlength'=>0.35)
  DCL::sgtxzr(0.5,0.68,"With 'log' option",0.022,0,0.0,22)

  #/ graph 32 /
  # log-level tone/contour (2)
  GGraph.set_fig('itr'=>1,'viewport'=>[0.2,0.85,0.22,0.58])
  GGraph.tone(gphys,true,'log'=>true, 'nlev'=>5, 'min'=>0.03, 'log_cycle'=>2 )
  GGraph.contour(gphys,false,'log'=>true, 'nlev'=>5, 'min'=>0.05, 'log_cycle'=>3)
  GGraph.color_bar('log'=>true, 'vlength'=>0.25)
  DCL::sgtxzr(0.5,0.68,"With 'log' option",0.022,0,0.0,22)


  #/ graph 33/
  # vector field on the polar coordinate (1)
  #  -- demo for flow_itr5 option of GGraph.vector

  #### create longitude, latitude, radial axes #####

  vrad = VArray.new( NArray.float(11).indgen! * 0.06 + 0.4 ).rename("rad")
  vlat = VArray.new( NArray.float(21).indgen! * 9 - 90 ).rename("lat")
  vlon = VArray.new( NArray.float(41).indgen! * 9 ).rename("lon")
  radax = Axis.new().set_pos(vrad)
  latax = Axis.new().set_pos(vlat)
  lonax = Axis.new().set_pos(vlon)
  grid_meridional = Grid.new(radax, latax)
  grid_equator = Grid.new(radax, lonax)

 #### create vector field in the meridional plane #####

  frad = vrad - 0.7
  frad = frad.reshape!(vrad.length,1)
  flat = (3*vlat/180*Math::PI).cos
  flat = flat.reshape!(1,vlat.length)
  vellat = frad*flat
  vellat.rename!('vellat')
  gp_vellat = GPhys.new(grid_meridional, vellat)

  frad = (vrad-0.4)*(vrad-1)
  frad = frad.reshape!(vrad.length,1)
  flat = (3*vlat/180*Math::PI).sin
  flat = flat.reshape!(1,vlat.length)
  velrad = frad*flat
  velrad.rename!('velrad')
  gp_velrad = GPhys.new(grid_meridional, velrad)

  #### draw vector field in the meridional plane #####

#  DCL.gropn(1)
#  GGraph.set_fig('viewport'=>[0.25,0.75,0.12,0.62])
  GGraph.next_fig('itr'=>5)
  GGraph.vector(gp_velrad, gp_vellat, true,
                'flow_itr5'=>true,'factor'=>1e-1)

  GGraph.next_fig('itr'=>5)
  GGraph.tone(gp_velrad,true)
  GGraph.vector(gp_velrad, gp_vellat, false,
                'flow_itr5'=>true,'factor'=>1e-1)

  #/ graph 34/
  # vector field on the polar coordinate (2)
  #  -- demo for flow_itr5 option of GGraph.vector

  #### create vector field in the equatorial plane #####

   frad = vrad - 0.7
   frad = frad.reshape!(vrad.length,1)
   flon = (3*vlon/180*Math::PI).cos
   flon = flon.reshape!(1,vlon.length)
   vellon = frad*flon
   vellon.rename!('vellon')
   gp_vellon = GPhys.new(grid_equator, vellon)

   frad = (vrad-0.4)*(vrad-1)
   frad = frad.reshape!(vrad.length,1)
   flon = (3*vlon/180*Math::PI).sin
   flon = flon.reshape!(1,vlon.length)
   velrad = frad*flon
   velrad.rename!('velrad')
   gp_velrad = GPhys.new(grid_equator, velrad)

  #### draw vector field in the equatorial plane #####

  GGraph.next_fig('itr'=>5)
  GGraph.vector(gp_velrad, gp_vellon, true,
                'flow_itr5'=>true,'factor'=>1e-1)

  GGraph.next_fig('itr'=>5)
  GGraph.tone(gp_velrad,true)
  GGraph.vector(gp_velrad, gp_vellon, false,
                'flow_itr5'=>true,'factor'=>1e-1)

  DCL.grcls

end
