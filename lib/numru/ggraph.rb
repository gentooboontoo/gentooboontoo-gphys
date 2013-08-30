require "numru/gphys"
require "numru/misc"
require "date"
require "numru/dclext"

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
  * ((<sim_trn?>))
    Returns whether the current coordinate transformation is a rectangular curvelinear coordinate.
  * ((<polar_coordinate_boundaries>))
    Draw boundaries in a polar coordinate.
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
  * ((<scatter>))
    Scatter diagram (using uumrkz, as in ((<mark>))).
  * ((<color_scatter>))
    Scatter diagram colored by values.
  * ((<tone_and_contour>))
    Calls ((<tone>)) and ((<contour>)) successively. 
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
       "map_rsat"    nil     # (Only for itr=30) satellite distance from the
                             # earth's center (Parameter "RSAT" for sgpack)
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
       "xloglabelall" false  # Show lavels for all log-level tick marks
                             # (x-axes) (e.g.,1000,900,800,... inseatd of
                             # 1000,500,200,...)
       "yloglabelall" false  # Show lavels for all log-level tick marks
                             # (y-axes) (e.g.,1000,900,800,... inseatd of
                             # 1000,500,200,...)
       "xmaplabel"   nil     # If "lon"("lat"), use
                             # DCLExt::lon_ax(DCLExt::lat_ax) to draw xaxes;
                             # otherwise, DCL::usxaxs is used.
       "ymaplabel"   nil     # If "lon"("lat"), use
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
       "slice"        nil    # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"          nil    # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"         nil    # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)
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
       "slice"        nil    # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"          nil    # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"         nil    # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)
       "help"        false   # show help message if true

    RETURN VALUE
    * nil


---scatter(fx, fy, newframe=true, options=nil)
    Scatter diagram (using uumrkz, as in ((<mark>))).

    ARGUMENTS
    * fx, fy (GPhys) : x and y locations.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
       option name  default value  # description:
       "title"      ""       # Title of the figure(if nil, internally determined)
       "annotate"   true     # if false, do not put texts on the right
                             # margin even when newframe==true
       "index"      1        # mark index
       "type"   2            # mark type
       "size"   0.01         # marks size
       "map_axes" false      # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "xintv"  1            # interval of data sampling in x
       "yintv"  1            # interval of data sampling in y
       "slice"  nil          # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"    nil          # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"   nil          # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)
       "help"   false        # show help message if true


---color_scatter(fx, fy, fz, newframe=true, options=nil)
    Scatter diagram colored by values.

    Coloring is made with respoect to fz just like in (<<tone>>).
    You can draw a color bar by calling (<<color_bar>>) after calling
    this method.

    ARGUMENTS
    * fx, fy (GPhys) : x and y locations.
    * fz (GPhys) : value on which colors are based.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
       option name  default value  # description:
       "title"      ""       # Title of the figure(if nil, internally determined)
       "annotate"   true     # if false, do not put texts on the right
                             # margin even when newframe==true
       "index"      3        # mark index (1-9)
       "type"   10           # mark type
       "size"   0.01         # marks size
       "map_axes" false      # [USE IT ONLY WHEN itr=10 (cylindrical)] If
                             # true, draws axes by temprarilly switching to
                             # itr=1 and calling GGraph::axes.
       "clr_min"  nil        # if an integer (in 10..99) is specified, used as
                             # the color number for the minimum data values.
                             # (the same can be done by setting the uepack
                             # parameter "icolor1")
       "clr_max"  nil        # if an integer (in 10..99) is specified, used as
                             # the color number for the maximum data values.
                             # (the same can be done by setting the uepack
                             # parameter "icolor2")
       "keep"	false        # Use the tone levels and patterns used previously
       "min"	nil          # minimum tone level
       "max"	nil	     # maximum tone level
       "nlev"	nil	     # number of levels
       "interval"	nil  # contour interval
       "help"	false        # show help message if true
       "log"	nil	     # approximately log-scaled levels (by using
                             # DCLExt::quasi_log_levels)
       "log_cycle"	3    # (if log) number of levels in one-order (1 or 2
                             # or 3)
       "levels"	nil	     # tone levels  (Array/NArray of Numeric). Works
                             # together with patterns
       "patterns"   nil  # Similar to the pattern option in (<<tone>>)),
                         # but here only the color part (4th and 5th 
                         # digitgs) is used. -- e.g, pattern 38999
                         # --> color 38.
       "xintv"  1            # interval of data sampling in x
       "yintv"  1            # interval of data sampling in y
       "slice"  nil          # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"    nil          # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"   nil          # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)
       "help"   false        # show help message if true
    
---add_mode_vectors(mean, modes, options)
    This method overlays mode vectors on scatter plots.
    Call this method after scatter / color_scatter.

    ARGUMENTS
    * mean : this determines the center of vectors
    * modes : two dimensional mode vectors (e.g. EOF modes) of the shape [2,2], [2,1], or [2].
              the first mode is modes[true,0] and the second mode is modes[true,1].
    * options (Hash) : options to change the default behavior if specified.
       option name  default value  # description:
       'lineindex'  1              # line index
       'linetype'   1              # line type
       'fact'       2              # scaling factor (line length = stddev * fact for each side)
       'style'      'line'         # style of displaying modes (line, arrow, ellipse)

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
       "log"	     nil     # approximately log-scaled levels (by using
                             # DCLExt::quasi_log_levels)
       "log_cycle"   3       # (if log) number of levels in one-order (1 or 2
                             # or 3)
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
       "xintv"        1      # interval of data sampling in x
       "yintv"        1      # interval of data sampling in y
       "xcoord"       nil    # Name of the coordinate variable for x-axis
       "ycoord"       nil    # Name of the coordinate variable for y-axis
       "slice"        nil    # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"          nil    # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"         nil    # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)

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
       "tonb"        false   # Use DCL.uetonb instead of DCL.uetone
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
       "color_bar"   false   # Add a color bar: THIS IS ONLY FOR QUICK
                             # LOOK. Use the GGraph::color_bar method explicitly
                             # for full option control
       "min"         nil     # minimum tone level
       "max"         nil     # maximum tone level
       "nlev"        nil     # number of levels
       "interval"    nil     # contour interval
       "help"        false   # show help message if true
       "log"	     nil     # approximately log-scaled levels (by using
                             # DCLExt::quasi_log_levels)
       "log_cycle"   3       # (if log) number of levels in one-order (1 or 2
                             # or 3)
       "levels"      nil     # tone levels  (Array/NArray of Numeric). Works
                             # together with patterns
       "patterns"    nil     # tone patters (Array/NArray of Numeric). Works
                             # together with levels
       "xintv"        1      # interval of data sampling in x
       "yintv"        1      # interval of data sampling in y
       "xcoord"       nil    # Name of the coordinate variable for x-axis
       "ycoord"       nil    # Name of the coordinate variable for y-axis
       "slice"        nil    # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"          nil    # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"         nil    # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)

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

---set_unit_vect_options(options)
---next_unit_vect_options(options)

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
       "ux_unit"     nil     # (If Numeric) length of the x direction unit
                             # vector (precedence of this option is lower than
                             # max_unit_vect)
       "uy_unit"     nil     # (If Numeric) length of the y direction unit
                             # vector (precedence of this option is lower than
                             # max_unit_vect)
       "help"        false   # show help message if true
       "xcoord"       nil    # Name of the coordinate variable for x-axis
       "ycoord"       nil    # Name of the coordinate variable for y-axis
       "slice"        nil    # An Array to be pathed to the GPhys#[] method to
                             # subset the data before plotting (order applied:
                             # slice -> cut -> mean)
       "cut"          nil    # An Array or Hash to be pathed to the GPhys#cut
                             # method to subset the data before plotting (order
                             # applied: slice -> cut -> mean)
       "mean"         nil    # An Array to be pathed to the GPhys#mean method to
                             # take mean of the data before plotting (order
                             # applied: slice -> cut -> mean)

    RETURN VALUE
    * nil

---set_regression_line(options)
    Change the default option values for ((<regression_line>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<regression_line>)).
    RETURN VALUE
    * a Hash containing the values replaced (the ones before calling this
      method)

---next_regression_line(options)
    Set the option values effective only in the next call of ((<regression_line>))
    (cleared then).

    These value are overwritten if specified explicitly in the next
    call of ((<regression_line>)).

    ARGUMENTS
    * options (Hash) : The usage is the same as (({options})) for ((<regression_line>)).
    RETURN VALUE
    * nil

---regression_line(x,y, options=nil)
    Draw a linear regression line in the current viewport.

    A figure must have been drawn. Good to call after ((<scatter>)) or
    ((<color_scatter>)). You can also use this method after any
    scatter plot (passively under non-GPhys environment), since the 
    argument x,y can be NArray etc unlike other draw methods in GGraph. 
     
    ARGUMENTS
    * x, y (GPhys or VArray or NArray or NArrayMiss or Array) : x and y values 

    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is
      unambiguous.
       option name      default value	# description:
       "x_given_y"   false   # If false (default), regress y for given x.
                             # If true, x given y.
       "annot_slope"  nil    # Whether to show the slope on the right
                             # margin. nil: show when itr=1,4, do not show when
                             # itr=2,3; true: show; false: not show
       "annot_intercept" false # [Meaningful only when itr=1 (linear
                             # scaling plot)] if true, show the intercept on the
                             # right margin
       "limit"      false    # If true, regression line is shown only over the
                             # range between max and min of the independent
                             # variable. If false, regression line is written
                             # over the whole range of the independent variable
       "clip"        true    # If true, use DCL's clipping not to show the line
                             # outside the viewport
       "index"          1    # line index
       "type"           1    # line type
       "help"       false    # show help message if true


=end
############################################################

module NumRu

  module GGraph

    # thresfold to swith uetonf and uetone under
    # the auto=true option in the tone method
    TONE_TONF_THRES_LEN = 100     # thresfold of length of each dimension
    TONE_TONF_THRES_SIZE = 20000  # thresfold of total size

    @@nannot = 0

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
      nannot = annotate_at(str_ary,vx,vy,charsize,-1.0,-1.5,noff)
      @@nannot = nannot
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
      ['map_rsat',nil,'(Only for itr=30) satellite distance from the earth\'s center (Parameter "RSAT" for sgpack)'],
      ['map_window', [-180,180,-75,75], '(for itr<20: cylindrical map projections) lon-lat window [lon_min, lon_max, lat_min, lat_max ] to draw the map (units: degrees)'],
      ['keep_axis_offset', false, 'keep offset of titles/labels from each axis (ROFFzs in UZPACK, effective only when new_frame is false)']
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
      !((1..9).include?(itr) || (51..99).include?(itr))
    end

    def itr_is?( itr, fig_yet_to_be_called=false )
      itr == current_itr( fig_yet_to_be_called )
    end

    def current_itr( fig_yet_to_be_called=false )
      if fig_yet_to_be_called
        current_itr = ( @@next_fig && @@next_fig['itr'] ) || @@fig['itr']
      else
        current_itr = DCL.sgqtrn
      end
      current_itr
    end

    def sim_trn?
      (5..7).include?(DCL.sgqtrn)
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
        if opts['keep_axis_offset'] # SAVE OFFSET VALUES
          offset_org = (%w(XT XB YL YR)).map{|zs| DCL::uzpget("ROFF#{zs}")}
        end
        DCL.grfig
      end
      raise "viewport's length must be 4" if opts['viewport'].length != 4
      DCL.grsvpt(*opts['viewport'])
      @@nannot = 0

      if opts['window']
        if !opts['window'].is_a?(Array) || opts['window'].length!=4
          raise "Option 'window' must be an Array of length==4"
        end
      end

      itr = opts['itr']
      DCL.grstrn(itr)

      map_fit = ( (itr==10 and opts['map_fit']!=false) or
                  (itr==11 and opts['map_fit']==true)  )
      DCL.sgpset("RSAT",opts['map_rsat']) if (opts['map_rsat'])

      if ( (1<=itr and itr<=4) or (51<=itr and itr<=99) or map_fit )
        window = opts['window']
        window = ( window ? window.dup : [nil, nil, nil, nil])
        if window.include?(nil)
          raise(ArgumentError, "xax and yax must be provided") if !xax or !yax
          if (xreverse=opts['xreverse']).is_a?(String)
            atts = opts['xreverse'].split(',').collect{|v| v.split(':')}
            xreverse = false
            atts.each{|key,val|
              xreverse = ( key.downcase=="units" ? (Units.new(xax.get_att(key)) =~ Units.new(val)) : (xax.get_att(key) == val) )
              break if xreverse
            }
          end
          if (yreverse=opts['yreverse']).is_a?(String)
            atts = opts['yreverse'].split(',').collect{|v| v.split(':')}
            yreverse = false
            atts.each{|key,val|
              yreverse = ( key.downcase=="units" ? (Units.new(yax.get_att(key)) =~ Units.new(val)) : (yax.get_att(key) == val) )
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
              if range[0] == range[1] # if min and max are still the same
                range[0] -= 1
                range[1] += 1
              end
            end
          end
          default_window=[xrange[0], xrange[1], yrange[0], yrange[1]]
          default_window = __round_window(default_window) if opts['round0']
          if (if [].respond_to?("nitems")  
                window.nitems == 0
              else
                window.none?
              end) # if all elements is nil
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
	if xax.rank==2 || yax.rank==2
	  if xax.rank==2
	    nx,ny = xax.shape
	  else
	    nx,ny = yax.shape
	  end
	  if x2d = (xax.rank==2)
	    ux = NArray.sfloat(nx).indgen!
	    cx = xax.val
	  else
	    ux = xax.val
	    cx = NArray.sfloat(nx,ny)
	    cx[0,0] = DCL::glrget('rundef')
	  end
	  if y2d = (yax.rank==2)
	    uy = NArray.sfloat(ny).indgen!
	    cy = yax.val
	  else
	    uy = yax.val
	    cy = NArray.sfloat(nx,ny)
	    cy[0,0] = DCL::glrget('rundef')
	  end
	  DCL::grswnd(0.0,ux.max,0.0,uy.max)
	  DCL::grscwd(*window)
	  DCL::g2sctr(ux,uy,cx,cy)
	  DCL::grstrn(51)
	  DCL.uwsgxa(ux)
	  DCL.uwsgya(uy)
	else
	  DCL.grswnd(*window)
	end
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

      when 10..19
        sv = DCL.umpget('lglobe')
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
          # 'lglobe' becomes true when itr >= 12 or data coverage is almost global for Mercator
          DCL.umpset('lglobe', (itr >= 12) || ((itr == 11) && (tyrange[0].abs >= 75) && (tyrange[1].abs >= 75) && (tyrange[0] * tyrange[1] < 0)))
        else
          lon_cent =( window[0] + window[1] ) / 2.0
          dlon2 = ( window[1] - window[0] ) / 2.0
          map_axis = [ lon_cent, 0.0, 0.0 ]
          DCL::sgswnd(*window)
          DCL::umscnt( *map_axis )
          DCL::grstxy( -dlon2, dlon2, window[2], window[3] )
          # 'lglobe' becomes true when data coverage is almost global for Mercator
          DCL.umpset('lglobe', (itr == 11) && (window[2].abs >= 75) && (window[3].abs >= 75) && (window[2] * window[3] < 0))
        end
        DCL::umpfit
      when 20..34
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
      if (!opts['new_frame']) && opts['keep_axis_offset'] # RESTORE OFFSET VALUES
        (%w(XT XB YL YR)).each_with_index{|zs, izs| DCL::uzpset("ROFF#{zs}", offset_org[izs])}
      end
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
      ['title',   nil,  'Title of the figure'],
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
      ['xloglabelall',  false,
               'Show lavels for all log-level tick marks (x-axes) (e.g.,1000,900,800,... inseatd of 1000,500,200,...)'],
      ['yloglabelall',  false,
               'Show lavels for all log-level tick marks (y-axes) (e.g.,1000,900,800,... inseatd of 1000,500,200,...)'],
      ['xmaplabel',  nil,
               'If "lon"("lat"), use DCLExt::lon_ax(DCLExt::lat_ax) to draw xaxes; otherwise, DCL::usxaxs is used.'],
      ['ymaplabel',  nil,
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
    def __calendar_ax(axtype, xax, side, sunits, calendar, ttl, \
                     tickint=nil, labelint=nil)
      window = DCL.sgqwnd
      viewport = DCL.sgqvpt
      /(.*) *since *(.*)/ =~ sunits
      if (!$1 or !$2)
        raise("Units mismatch. Requires time units that includes 'since'")
      end
      tun = Units[$1]
      dayun = Units['days']
      if xax
        t0 = window[0]
        t1 = window[1]
      else
        t0 = window[2]
        t1 = window[3]
      end
      time = UNumeric.new(t0,sunits)
      tstr = time.to_datetime(0.1,calendar)
      jd0 = tstr.strftime('%Y%m%d').to_i
      tlen = tun.convert( t1-t0, dayun )
      axtype ||= (tlen < 5) ? 'h' : 'ymd'

      if xax
        DCL.grswnd(0.0, tlen, window[2], window[3] )
        DCL.grstrf
        opts = {'cside'=>side}
        opts['dtick1'] = tickint if tickint
        opts['dtick2'] = labelint if labelint
        if axtype == 'h'
          DCLExt.datetime_ax(tstr, tstr+tlen, opts )
        else
          DCLExt.date_ax(tstr, tstr+tlen, opts )
          ## DCL.ucxacl(side,jd0,tlen)  #Old: use it again if UCPACK is improved
        end
      else
        DCL.grswnd(window[0], window[1], 0.0, tlen)
        DCL.grstrf
        opts = {'yax'=>true, 'cside'=>side}
        opts['dtick1'] = tickint if tickint
        opts['dtick2'] = labelint if labelint
        if axtype == 'h'
          DCLExt.datetime_ax(tstr, tstr+tlen, opts )
        else
          DCLExt.date_ax(tstr, tstr+tlen, opts )
          ## DCL.ucyacl(side,jd0,tlen)  #Old: use it again if UCPACK is improved
        end
      end
      DCL.grswnd(*window)
      DCL.grstrf
    end
    private :__calendar_ax

    def axes(xax=nil, yax=nil, options=nil)
      if @@next_axes
        options = ( options ? @@next_axes.update(options) : @@next_axes )
        @@next_axes = nil
      end
      opts = @@axes.interpret(options)
      if itr51 = (DCL.sgqtrn == 51)
	wnd = DCL::sgqwnd
	DCL::sgswnd( *(cwd = DCL::sgqcwd) )
	DCL::sgstrn(1)
	DCL::sgstrf
      end
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
             /since/ =~ sunits && units =~ Units['days since 0001-01-01'] && \
             ( calendar = ( xax.get_att('calendar') || nil ) ; \
               UNumeric::supported_calendar?(calendar) )
            opts['xside'].split('').each do |s|   # scan('.') also works
              ttl = opts['xtitle'] || xai['title']
              __calendar_ax(opts['time_ax'], true, s, sunits, calendar, ttl,
                	   opts['xtickint'], opts['xlabelint'])
            end
          else
            DCL.uscset('cxttl', (opts['xtitle'] || xai['title']) )
            DCL.uscset('cxunit', sunits)
            DCL.uspset('dxt', opts['xtickint'])  if(opts['xtickint'])
            DCL.uspset('dxl', opts['xlabelint']) if(opts['xlabelint'])
            if(opts['xloglabelall'])
              DCL.uspset('nlblx', 4)
              DCL.ulsxbl([1,2,3,4,5,6,7,8,9])
            end
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
             /since/ =~ sunits && units =~ Units['days since 0001-01-01'] && \
             ( calendar = ( yax.get_att('calendar') || nil ) ; \
               UNumeric::supported_calendar?(calendar) )
            opts['yside'].split('').each do |s|   # scan('.') also works
              ttl = opts['ytitle'] || yai['title']
              __calendar_ax(opts['time_ax'], false, s, sunits, calendar, ttl,
                	   opts['ytickint'], opts['ylabelint'])
            end
          else
            DCL.uscset('cyttl', (opts['ytitle'] || yai['title']) )
            DCL.uscset('cyunit', sunits )
            DCL.uspset('dyt', opts['ytickint'])  if(opts['ytickint'])
            DCL.uspset('dyl', opts['ylabelint']) if(opts['ylabelint'])
            if(opts['yloglabelall'])
              DCL.uspset('nlbly', 4)
              DCL.ulsybl([1,2,3,4,5,6,7,8,9])
            end
            opts['yside'].split('').each{|s|   # scan('.') also works
              DCL.usyaxs(s)
              if s=='l' && sunits && sunits != ''
                DCL.uzpset('roffxt', DCL.uzpget('rsizec1')*1.5 )
              end
            }
          end
        end
	title(opts['title']) if opts['title']
      end
      if itr51
	DCL::sgstrn(51)
	DCL::sgswnd( *wnd )
	DCL::sgscwd( *cwd )
	DCL::sgstrf
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
        #raise "Not 1D" if vary.rank!=1
        hash = {
                'title'=>(vary.long_name || vary.name), #.gsub('_','' )
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

    @@data_prep_options =  Misc::KeywordOptAutoHelp.new(
      ['exchange', false, 'whether to exchange x and y axes'],
      ['transpose', false, 'if true, exchange x and y axes'],
      ['xintv', 1, 'interval of data sampling in x'],
      ['yintv', 1, 'interval of data sampling in y'],
      ['xcoord', nil, 'Name of the coordinate variable for x-axis'],
      ['ycoord', nil, 'Name of the coordinate variable for y-axis'],
      ['slice', nil, 'An Array to be pathed to the GPhys#[] method to subset the data before plotting (order applied: slice -> cut -> mean)'],
      ['cut', nil, 'An Array or Hash to be pathed to the GPhys#cut method to subset the data before plotting (order applied: slice -> cut -> mean)'],
      ['mean', nil, 'An Array to be pathed to the GPhys#mean method to take mean of the data before plotting (order applied: slice -> cut -> mean)']
    )

    def data_prep_2D(gps, newframe, opts)
      opend_here = []
      gps.collect!{|gp| 
        if gp.is_a?(String)
          gp = GPhys::IO.str2gphys(gp)
          opend_here.push(gp) 
        end
        gp = gp[*opts['slice']] if opts['slice']
        if (cut = opts['cut'])  # substitution, not ==
          if cut.is_a?(Array) 
            gp = gp.cut(*cut) 
          else
            gp = gp.cut(cut) 
          end
        end
        gp = gp.mean(*opts['mean']) if opts['mean']
        gp = gp.first2D
        gp = gp.transpose(1,0) if opts['transpose'] || opts['exchange']
        if opts['xintv'] || opts['yintv']
          gp = gp.copy
          sh = gp.shape
          if opts['xintv'] && ((xi=opts['xintv']) >= 2)
            idx = NArray.int((sh[0]/xi.to_f).ceil).indgen!*xi  # 0,xi,2*xi,..
            gp = gp[idx, true]
          end
          if opts['yintv'] && ((yi=opts['yintv']) >= 2)
            idx = NArray.int((sh[1]/yi.to_f).ceil).indgen!*yi  # 0,yi,2*yi,..
            gp = gp[true, idx]
          end
        end
        gp
      }
      if opend_here.length > 0
        closer = Proc.new{opend_here.each{|gp| gp.data.file.close}}
      else
        closer = nil
      end
      xd = gps[0].coord(0)
      yd = gps[0].coord(1)
      if xc=opts['xcoord']
        xa = gps[0].coord(xc)
        if xa.rank == 1 && xa.length != xd.length
	  raise("Len of #{xc} do not agree with the #{xd.name} dim")
	elsif xa.rank == 2 && xa.shape != gps[0].shape
	  raise("Invalid 2D coord shape. #{xc} : #{xa.shape.inspect}" +
		" vs #{gps[0].shape.inspect}")
        end
	xd = xa
      end
      if yc=opts['ycoord']
        ya = gps[0].coord(yc)
        if ya.rank == 1 && ya.length != yd.length
	  raise("Len of #{yc} do not agree with the #{yd.name} dim")
	elsif ya.rank == 2 && ya.shape != gps[0].shape
	  raise("Invalid 2D coord shape. #{yc} : #{ya.shape.inspect}" +
		" vs #{gps[0].shape.inspect}")
        end
	yd = ya
      end
      if map_trn?(newframe)
        # // convert to the anti-clockwise coordinate in case for map filling
        #    (Because of a bug in UMFMAP in DCL 5.3)  -->
        if ( (xd[-1].val-xd[0].val)*(yd[-1].val-yd[0].val) < 0 )
          gps.collect!{|gp| gp.copy[true,-1..0]}
          yd = gps[0].coord(1)
        end
        # <-- ///
        gps.collect!{|gp| gp.cyclic_ext(0, 360.0)} #cyclic extentn along lon
        xd = gps[0].coord(0)
      elsif itr_is?(5, newframe)
        gps.collect!{|gp| gp.cyclic_ext(1, 360.0)} #cyclic ext along azimuth
        yd = gps[0].coord(1)
      end
      [xd, yd, closer, *gps]
    end

    def data_prep_1D(gphys, opts)
      gp = gphys
      if gp.is_a?(String)
        gp = GPhys::IO.str2gphys(gp) 
        closer = Proc.new{gp.close}
      else
        closer = nil
      end
      gp = gp[*opts['slice']] if opts['slice']
      if (cut = opts['cut'])  # substitution, not ==
        if cut.is_a?(Array) 
          gp = gp.cut(*cut) 
        else
          gp = gp.cut(cut) 
        end
      end
      gp = gp.mean(*opts['mean']) if opts['mean']
      gp = gp.first1D
      window = ( @@next_fig['window'] if @@next_fig ) || @@fig['window']
      window = ( window ? window.dup : [nil, nil, nil, nil])
      max = opts['max']; min = opts['min']
      if !opts['exchange']
        xd = gp.coord(0)
        yd = gp.data
        window[2] = min if min
        window[3] = max if max
      else
        yd = gp.coord(0)
        xd = gp.data
        window[0] = min if min
        window[1] = max if max
      end
      [xd, yd, closer, gp, window]
    end        

    def data_prep_1D2(fx, fy, opts)
      gpx = fx
      gpy = fy
      to_close = Array.new
      if gpx.is_a?(String)
        gpx = GPhys::IO.str2gphys(gpx) 
        to_close.push(gpx)
      end
      if gpy.is_a?(String)
        gpy = GPhys::IO.str2gphys(gpy) 
        to_close.push(gpy)
      end
      if to_close.length > 0
        closer = Proc.new{to_close.each{|gp| gp.close}}
      else
        closer = nil
      end

      gpx = gpx[*opts['slice']] if opts['slice']
      if (cut = opts['cut'])  # substitution, not ==
        if cut.is_a?(Array) 
          gpx = gpx.cut(*cut) 
        else
          gpx = gpx.cut(cut) 
        end
      end
      gpx = gpx.mean(*opts['mean']) if opts['mean']
      gpx = gpx.first1D

      gpy = gpy[*opts['slice']] if opts['slice']
      if (cut = opts['cut'])  # substitution, not ==
        if cut.is_a?(Array) 
          gpy = gpy.cut(*cut) 
        else
          gpy = gpy.cut(cut) 
        end
      end
      gpy = gpy.mean(*opts['mean']) if opts['mean']
      gpy = gpy.first1D

      [gpx, gpy, closer]
    end        

    def data_prep_multidim(gphys, opts)
      gp = gphys
      if gp.is_a?(String)
        gp = GPhys::IO.str2gphys(gp) 
        closer = Proc.new{gp.close}
      else
        closer = nil
      end
      gp = gp[*opts['slice']] if opts['slice']
      if (cut = opts['cut'])  # substitution, not ==
        if cut.is_a?(Array) 
          gp = gp.cut(*cut) 
        else
          gp = gp.cut(cut) 
        end
      end
      gp = gp.mean(*opts['mean']) if opts['mean']
      [gp, closer]
    end        

    @@line_options = Misc::KeywordOptAutoHelp.new(
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
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
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['step_plot', false, 'If true, draw stair step plot (piecewise constant line plot).'],
      # ['step_extend_ends', false, 'If true, extend both ends of stair step plot.'], # NOT YET IMPLEMENTED
      ['step_position', 0, 'Data point will be at the right corner of each step if negative, center if 0, and left corner if positive.'],
      @@data_prep_options
    )

    def set_step_plot_position(val, postype)
      if postype == 0
        val = NArray.to_na([val[0]] + (val[0..-2] + val[1..-1]).mul!(0.5).to_a + [val[-1]])
      elsif postype > 0
        val = NArray.to_na([val[0]] + val.to_a)
      else
        val = NArray.to_na(val.to_a + [val[-1]])
      end
      return val
    end
    private :set_step_plot_position

    def line(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      opts = @@line_options.interpret(options)
      x, y, closer, gp, window = data_prep_1D(gphys, opts)
      if newframe
        fig(x, y, {'window'=>window})
        axes_or_map_and_ttl(gp, opts, x, y)
      end

      if opts['label']
        lcharbk = DCL.sgpget('lchar')
        DCL.sgpset('lchar',true)
        DCL.sgsplc(opts['label'])
      end
      if opts['step_plot']
        if opts['exchange']
          yval = set_step_plot_position(y.val, opts['step_position'])
          DCL.uhbxlz(x.val, yval, opts['type'], opts['index'])
        else
          xval = set_step_plot_position(x.val, opts['step_position'])
          DCL.uvbxlz(xval, y.val, opts['type'], opts['index'])
        end
      else
        DCL.uulinz(x.val, y.val, opts['type'], opts['index'])
      end
      DCL.sgpset('lchar',lcharbk) if opts['label']

      legend = opts['legend']
      if legend
        legend = gp.name if legend==true
        DCLExt::legend(legend,opts['type'],opts['index'],true,
                       opts['legend_size'],opts['legend_vx'],opts['legend_dx'],
                       opts['legend_vy'],newframe)
      end
      closer.call if closer
      nil
    end
#---------------------------------------------------------- Added at 080207 --
    def profile(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      
      opts = @@line_options.interpret(options)
      check_max = opts['max']
      opts['max'] = nil
      opts['exchange']= true
      x, y, closer, gp, window = data_prep_1D(gphys, opts)

      if newframe
        fig(x, y, {'window'=>window})
        axes_or_map_and_ttl(gp, opts, x, y)
      end
      if opts['label']
        lcharbk = DCL.sgpget('lchar')
        DCL.sgpset('lchar',true)
        DCL.sgsplc(opts['label'])
      end

      if opts['index']
         iat=opts['index']
      end
      if check_max
         if x.val.max > check_max
            iat=21
         end
      end
      DCL.uulinz(x.val, y.val, opts['type'], iat )
      DCL.sgpset('lchar',lcharbk) if opts['label']


      legend = opts['legend']
      if legend
        legend = gp.name if legend==true
        DCLExt::legend(legend,opts['type'],opts['index'],true,
                       opts['legend_size'],opts['legend_vx'],opts['legend_dx'],
                       opts['legend_vy'],newframe)
      end
      closer.call if closer
      nil
    end
#-----------------------------------------------------------------------------

    @@mark_options = Misc::KeywordOptAutoHelp.new(
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['index', 1, 'mark index'],
      ['type', 2, 'mark type'],
      ['size', 0.01, 'marks size'],
      ['max', nil, 'maximam data value'],
      ['min', nil, 'minimam data value'],
      ['legend', nil, 'legend to annotate the mark type, index, and size. nil (defalut -- do not to show); a String as the legend; true to use the name of the GPhys as the legend'],
      ['legend_vx', nil, '(effective if legend) viewport x values of the lhs of the legend line (positive float); or nil for automatic settting (shown to the right of vpt); or move it to the left relatively (negtive float)'],
      ['legend_vy', nil, '(effective if legend) viewport y value of the legend (Float; or nil for automatic settting)'],
      ['legend_size', nil, '(effective if legend) character size of the legend'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      @@data_prep_options
        )

    def mark(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      opts = @@mark_options.interpret(options)
      x, y, closer, gp, window = data_prep_1D(gphys, opts)
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
      closer.call if closer
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

######################################################  timeplot 0802011 ######
    def timeplot(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      if ! defined?(@@timeplot_options)
        @@timeplot_options = Misc::KeywordOptAutoHelp.new(
          ['size', 0.01, 'marks size'],
          ['lamin', nil, 'minimam latitude value'],
          ['lamax', nil, 'maximam latitude value'],
          ['lomin', nil, 'minimam longitude value'],
          ['lomax', nil, 'maximam longitude value'],
          ['ltone', true, 'Same as udpack parameter ltone'],
          ['tonf', false, 'Use DCL.uetonf instead of DCL.uetone'],
          ['tonb', false, 'Use DCL.uetonb instead of DCL.uetone'],
          ['tonc', false, 'Use DCL.uetonc instead of DCL.uetone'],
          ['clr_min', 13,  'if an integer (in 10..99) is specified, used as the color number for the minimum data values. (the same can be done by setting the uepack parameter "icolor1")'],
          ['clr_max', 99,  'if an integer (in 10..99) is specified, used as the color number for the maximum data values. (the same can be done by setting the uepack parameter "icolor2")'],
          ['keep', false, 'Use the tone levels and patterns used previously'],
          @@line_options
        )
      end

      opts = @@timeplot_options.interpret(options)
      opts['type'] = 2
      if opts['clr_min']
        icolor1_bak = DCL.uepget('icolor1')
        DCL.uepset('icolor1', opts['clr_min'])
      end
      if opts['clr_max']
        icolor2_bak = DCL.uepget('icolor2')
        DCL.uepset('icolor2', opts['clr_max'])
      end
      cmn=opts['clr_min']+1
      cmx=opts['clr_max']-1

      if opts['lamin'] && opts['lamax']
         latmn= opts['lamin']
         latmx= opts['lamax']
         if latmn > latmx
            raise ArgumentError,"Specific Settings parameter is invalid.(1)"
         end
      elsif opts['lamin'] || opts['lamax']
         raise ArgumentError,"Specific Settings parameter is invalid.(2)"
      else
         latmn=false
         latmx=false
      end

      if opts['lomin'] && opts['lomax']
         lonmn= opts['lomin']
         lonmx= opts['lomax']
         if lonmn > lonmx
            raise ArgumentError,"Specific Settings parameter is invalid.(3)"
         end
      elsif opts['lomin'] || opts['lomax']
         raise ArgumentError,"Specific Settings parameter is invalid.(4)"
      else
         lonmn=false
         lonmx=false
      end

      gp = gphys.first2D
      gp = gp.transpose(1,0) if opts['transpose'] || opts['exchange']
#--
      x = gp.coord(0)
      y = gp.coord(1)
      zv = gp.data.val
           
      idim=0
      case x.name.downcase
      when "time"
         idim=0
      else
         case y.name.downcase
         when "time"
           idim=1
         end
      end

      latp=VArray.new
      lonp=VArray.new
      lat_flag = false
      lon_flag = false
      if gp.has_assoccoord?
        gp.assoc_coords.coordnames.each do |auxname|
          if auxname == "Latitude"
            latp=gp.coord(auxname)
            lat_flag = true
          elsif auxname == "Longitude"
            lonp=gp.coord(auxname)
            lon_flag = true
          end
        end
      end

      #------ for color bar
      DCL.uwsgxa(x.val)
      DCL.uwsgya(y.val)
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
      #-------
      if newframe
        fig(x, y)
        axes_or_map_and_ttl(gp, opts, x, y)
      end
      zmn=gp.data.val.min
      zmx=gp.data.val.max

      zmax = ((cmx-cmn)+cmn).round*10+3
      zmin = cmn.round*10+3
      #-------
      xx=x.val.to_a
      yy=y.val.to_a
      plat=latp.val.to_a if lat_flag
      plon=lonp.val.to_a if lon_flag
      zz=zv

      k=0
      for i in 0..yy.length-1
        for j in 0..xx.length-1
           tflg=0
           idim == 0 ? h=j : h=i

           tflg=1 if latmn && latmx && ( plat[h] < latmn || plat[h] > latmx )
           tflg=2 if lonmn && lonmx && ( plon[h] < lonmn || plon[h] > lonmx )
           if tflg == 0
              xx1=NArray.to_na(Array.new(1,xx[j]*1.0))
              yy1=NArray.to_na(Array.new(1,yy[i]*1.0))
              z = zz[j,i] if zz[j,i].is_a?(Numeric)
              z = zmn if zz[j,i].is_a?(Array)
              iz=((z-zmn)/(zmx-zmn)*(cmx-cmn)+cmn).round*10+3
              DCL.uumrkz(xx1, yy1, 230, iz, 0.005 )
           end
           k+=1
        end
      end

      legend = opts['legend']
      if legend
        legend = gp.name if legend==true
        DCLExt::legend(legend,opts['type'],opts['index'],false,
                       opts['legend_size'],opts['legend_vx'],nil,
                       opts['legend_vy'],newframe,opts['size'])
      end
      DCL.uepset('icolor1', icolor1_bak) if opts['clr_min']
      DCL.uepset('icolor2', icolor2_bak) if opts['clr_max']
      #----------------------------- color bar unit -- 08.01.31 ----
      vx1, vx2, vy1, vy2 = DCL.sgqvpt
      x1=vx2+0.02
      y1=vy1-0.02
      if  "#{gp.data.units}".length >0
          DCL.sgtxzv(x1, y1, "#{gp.data.units}", 0.02, 0, -1 ,11 )
      end
      #-----------------------------------------
      nil
    end

#########################################################################

    def tone_and_contour(gphys, newframe=true, options=nil)
      options ? copt=@@contour_options.select_existent(options) : copt=nil
      options ? topt=@@tone_options.select_existent(options) : topt=nil
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
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['keep', false, 'Use the contour levels used previously'],
      @@linear_contour_options,
      @@contour_levels,
      @@data_prep_options
    )

    def name_selector(gp, limit)
      if gp.long_name && gp.name
        if gp.long_name.length > limit && gp.long_name.length > gp.name.length && !gp.name.empty?
          gp.name 
        else 
          gp.long_name
        end
      else
        gp.long_name || gp.name
      end
    end
    private :name_selector

    def axes_or_map_and_ttl(gp, opts, xax, yax, gp2=nil)
      if !gp2
        ttl = opts['title'] || name_selector(gp, 30)
      else
        ttl = opts['title'] || '(' << name_selector(gp, 15) << ',' << name_selector(gp2, 15) << ')'
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
            fig(xax,yax, {'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt, 'keep_axis_offset'=>true})
            axes(xax, yax, 'title'=>ttl)
            fig(xax,yax,{'itr'=>trn, 'new_frame'=>false, 'viewport'=>vpt, 'map_fit'=>true, 'keep_axis_offset'=>true})
          else
            xax_map = xax[0..1].copy
            xax_map[0] = cnt[0] + wnd[0]
            xax_map[1] = cnt[0] + wnd[1]
            yax_map = yax[0..1].copy
            yax_map[0] = wnd[2]
            yax_map[1] = wnd[3]
            fig(xax_map,yax_map,{'itr'=>1, 'new_frame'=>false, 'viewport'=>vpt, 'keep_axis_offset'=>true})
            axes(xax_map, yax_map, 'title'=>ttl)
            fig(xax_map,yax_map,{'itr'=>trn, 'new_frame'=>false, 'viewport'=>vpt, 'map_fit'=>false, 'map_axis'=>cnt, 'map_window'=>wnd, 'keep_axis_offset'=>true})
          end
        else
          title( ttl )
        end
      elsif itr_is?(5)
        polar_coordinate_boundaries(xax,yax)
        title( ttl )
      else
        axes(xax, yax, 'title'=>ttl)
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

      xax, yax, closer, gp = data_prep_2D([gphys], newframe, opts)
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
      DCL.uwsgxa(xax.val) if xax.rank==1
      DCL.uwsgya(yax.val) if yax.rank==1
      DCL.udcntz(gp.data.val)
      DCLExt.ud_set_params(saved_udparams) if saved_udparams
      closer.call if closer
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
      ['ltone', true, 'Same as uepack parameter ltone'],
      ['auto', true, 'Swith DCL.uetone and DCL.uetonf depending on the data size'],
      ['tonf', false, 'Use DCL.uetonf instead of DCL.uetone'],
      ['tonb', false, 'Use DCL.uetonb instead of DCL.uetone'],
      ['tonc', false, 'Use DCL.uetonc instead of DCL.uetone'],
      ['clr_min', nil,  'if an integer (in 10..99) is specified, used as the color number for the minimum data values. (the same can be done by setting the uepack parameter "icolor1")'],
      ['clr_max', nil,  'if an integer (in 10..99) is specified, used as the color number for the maximum data values. (the same can be done by setting the uepack parameter "icolor2")'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['keep', false, 'Use the tone levels and patterns used previously'],
      ['color_bar', false, 'Add a color bar: THIS IS ONLY FOR QUICK LOOK. Use the GGraph::color_bar method explicitly for full option control'],
      @@linear_tone_options,
      @@tone_levels,
      @@data_prep_options
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
      xax, yax, closer, gp = data_prep_2D([gphys], newframe, opts)

      if opts['clr_min']
        icolor1_bak = DCL.uepget('icolor1')
        DCL.uepset('icolor1', opts['clr_min'])
      end
      if opts['clr_max']
        icolor2_bak = DCL.uepget('icolor2')
        DCL.uepset('icolor2', opts['clr_max'])
      end
      if newframe
        fig(xax, yax)
      end
      DCL.uwsgxa(xax.val) if xax.rank==1
      DCL.uwsgya(yax.val) if yax.rank==1
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

      val = gp.data.val
      if ( opts['ltone'] && 
          ( opts['tonf'] || opts['auto'] && 
            ( val.length >= TONE_TONF_THRES_SIZE || val.shape.min >= TONE_TONF_THRES_LEN ) ) )
        DCL.uetonf(val)
      elsif opts['tonb'] && opts['ltone']
        DCL.uetonb(val)
      elsif opts['tonc'] && opts['ltone']
        DCL.uetonc(val)
      else
        DCL.uetone(val)
      end

      if newframe
        axes_or_map_and_ttl(gp,opts, xax, yax)
      end
      DCL.uepset('icolor1', icolor1_bak) if opts['clr_min']
      DCL.uepset('icolor2', icolor2_bak) if opts['clr_max']

      if opts['color_bar']
        color_bar "log"=>opts['log']
      end
      closer.call if closer
      nil
    end

    # < scatter diagram >

    @@scatter_options = Misc::KeywordOptAutoHelp.new(
      ['title', "", 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['index', 1, 'mark index'],
      ['type', 2, 'mark type'],
      ['size', 0.01, 'marks size'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['correlation', false, 'calculate Pearson\'s correlation coefficient and show it on the bottom margin'],
      @@data_prep_options
        )
    ## @@scatter_options.delete("transpose")   # delete is yet to be supported
    ## @@scatter_options.delete("exchange")    # (2010-01)

    def set_scatter(options)
      @@scatter_options.set(options)
    end
    @@next_scatter = nil
    def next_scatter(options)
      if options.is_a?(Hash)
        @@next_scatter = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def scatter(fx, fy, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "3rd arg (newframe) must be true or false"
      end
      if @@next_scatter
        options = ( options ? @@next_scatter.update(options) : @@next_scatter )
        @@next_scatter = nil
      end
      opts = @@scatter_options.interpret(options)
      # interpret cut, slice, etc
      gpx, closerx = data_prep_multidim(fx, opts)
      gpy, closery = data_prep_multidim(fy, opts)
      # flatten gphys data -----
      fakeaxis = Axis.new.set_pos(VArray.new(NArray.int(gpx.length).indgen!,
                                             {"long_name"=>"fake",
                                               "units"=>""},
                                             "fake"))
      fakegrid = Grid.new(fakeaxis)
      gpx, gpy = [gpx, gpy].collect{|gp|
        na = gp.val.reshape!(gp.length)
        attr = gp.data.attr_copy
        newgp = GPhys.new(fakegrid,VArray.new(na,attr,gp.name))
        newgp.set_lost_axes(gp.lost_axes)
        newgp
      }
      # ------------------------
      x = gpx.data
      y = gpy.data
      if newframe
        fig(x, y)
        axes_or_map_and_ttl(gpx, opts, x, y, gpy)
      end
      DCL.uumrkz(x.val, y.val, opts['type'], opts['index'], opts['size'])
      if opts['correlation']
        return _scatter_display_corr(gpx, gpy, opts) 
      else
        return nil
      end
      # close if necessary -----
      closerx.call if closerx
      closery.call if closery
      nil
    end

    # < scatter diagram colored by values >

    @@color_scatter_options = Misc::KeywordOptAutoHelp.new(
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['index', 3, 'mark index (1-9)'],
      ['type', 10, 'mark type'],
      ['size', 0.01, 'marks size'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['clr_min', nil,  'if an integer (in 10..99) is specified, used as the color number for the minimum data values. (the same can be done by setting the uepack parameter "icolor1")'],
      ['clr_max', nil,  'if an integer (in 10..99) is specified, used as the color number for the maximum data values. (the same can be done by setting the uepack parameter "icolor2")'],
      ['keep', false, 'Use the tone levels and patterns used previously'],
      ['correlation', false, 'calculate Pearson\'s correlation coefficient and show it on the bottom margin'],
      @@linear_tone_options,
      @@tone_levels,
      @@data_prep_options
        )
    ## @@color_scatter_options.delete("transpose")   # delete is yet to be supported
    ## @@color_scatter_options.delete("exchange")    # (2010-01)

    def set_color_scatter(options)
      @@color_scatter_options.set(options)
    end
    @@next_color_scatter = nil
    def next_color_scatter(options)
      if options.is_a?(Hash)
        @@next_color_scatter = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def color_scatter(fx, fy, fz, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "4th arg (newframe) must be true or false"
      end
      if @@next_color_scatter
        options = ( options ? @@next_color_scatter.update(options) : @@next_color_scatter )
        @@next_color_scatter = nil
      end
      opts = @@color_scatter_options.interpret(options)
      # interpret cut, slice, etc
      gpx, closerx = data_prep_multidim(fx, opts)
      gpy, closery = data_prep_multidim(fy, opts)
      gpz, closerz = data_prep_multidim(fz, opts)
      # flatten gphys data -----
      fakeaxis = Axis.new.set_pos(VArray.new(NArray.int(gpx.length).indgen!,
                                             {"long_name"=>"fake",
                                               "units"=>""},
                                             "fake"))
      fakegrid = Grid.new(fakeaxis)
      gpx, gpy, gpz = [gpx, gpy, gpz].collect{|gp|
        na = gp.val.reshape!(gp.length)
        attr = gp.data.attr_copy
        newgp = GPhys.new(fakegrid,VArray.new(na,attr,gp.name))
        newgp.set_lost_axes(gp.lost_axes)
        newgp
      }
      # ------------------------
      xax = gpx.data
      yax = gpy.data
      if newframe
        fig(xax, yax)
        axes_or_map_and_ttl(gpz, opts, xax, yax)
      end

      zval = gpz.data.val

      # < levels setting --- taken from tone >

      if opts['clr_min']
        icolor1_bak = DCL.uepget('icolor1')
        DCL.uepset('icolor1', opts['clr_min'])
      end
      if opts['clr_max']
        icolor2_bak = DCL.uepget('icolor2')
        DCL.uepset('icolor2', opts['clr_max'])
      end

      rmiss = DCL.glrget('rmiss')

      if !opts['keep'] or DCL.ueqntl==0
        if !opts['levels'] && opts['log']
          levels, = DCLExt.quasi_log_levels_z(zval, opts['nlev'],
                                  opts['max'], opts['min'], opts['log_cycle'])
          levels.unshift(rmiss) if !opts['max'] && levels[0]<0
          levels.push(rmiss)    if !opts['max'] && levels[-1]>0
          opts['levels'] = levels
        end
        if opts['levels']
          backup = @@set_tone_levels
          _set_tone_levels_(opts)
          @@set_tone_levels = backup
        elsif opts['patterns']
          # Here only the colors are used from patterns
          raise "option 'patterns' is not effective unless 'levels' is specified"
        elsif !@@set_tone_levels
          DCL.ueitlv
          DCLExt.ue_set_linear_levs(zval, opts)
        else
          DCL.ueitlv if !@@set_tone_levels
        end
      end
      DCL::uemrkz(xax.val, yax.val, zval, opts['type'], opts['index'], opts['size'])
      if opts['correlation']
        return _scatter_display_corr(gpx, gpy, opts) 
      else
        return nil
      end
      #< finish >
    ensure
      DCL.uepset('icolor1', icolor1_bak) if opts['clr_min']
      DCL.uepset('icolor2', icolor2_bak) if opts['clr_max']
      closerx.call if closerx
      closery.call if closery
      closerz.call if closerz
    end

    def _scatter_display_corr(gpx, gpy, opts)
      require "numru/ganalysis/covariance" 
      r, n = gpx.correlation(gpy,0)
      r = r.val if r.is_a?(GPhys)
      DCL::uxsttl("B","r=#{DCL.chval('A',r)}", 0)
      return [r, n]
    end
    private :_scatter_display_corr

    @@add_mode_vectors_options = Misc::KeywordOptAutoHelp.new(
      ['lineindex', 1, 'line index'],
      ['linetype', 1, 'line type'],
      ['fact', 2, 'scaling factor (line length = stddev * fact for each side)'],
      ['style', 'line', 'style of displaying modes (line, arrow, ellipse)']
        )
    def add_mode_vectors(mean, modes, options=nil)
      opts = @@add_mode_vectors_options.interpret(options)
      unless modes.shape == [2,2] || modes.shape[2,1] || modes.shape == [2]
        raise ArgumentError, "the second arg must be a NArray of the shape [2,2], [2,1], or [2]."
      end
      unless (mean.length == 2) && (mean.is_a?(GPhys) || mean.is_a?(NArray) || mean.is_a?(Array))
        raise ArgumentError, "the 1st arg must be a GPhys, NArray, or Array with length of 2" 
      end
      mean = mean.val if mean.is_a?(GPhys)
      modes = modes.val * opts['fact']
      index = opts['lineindex']
      type = opts['linetype']
      modes = modes.newdim(-1) if modes.rank == 1
      for i in 0...(modes.shape[1])
        case opts['style']
        when "line"
          DCL::sgplzu([mean[0]-modes[0,i],mean[0]+modes[0,i]],
                      [mean[1]-modes[1,i],mean[1]+modes[1,i]],
                      type,index)
        when "arrow"
          DCL::sglazu(mean[0]-modes[0,i],mean[1]-modes[1,i],
                      mean[0]+modes[0,i],mean[1]+modes[1,i],
                      type,index)
        when "ellipse"
          raise "Drawing an ellipse needs two modes" unless modes.shape[1]==2
          arg = NArray.int(361).indgen!.to_f / 180.0 * NMath::PI
          s = NMath.sin(arg)
          c = NMath.cos(arg)
          x = mean[0] + modes[0,0] * c + modes[0,1] * s
          y = mean[1] + modes[1,0] * c + modes[1,1] * s
          DCL::sgplzu(x,y,type,index)
        else
          raise "invalid value for the option 'style' in add_mode_vectors: #{kind}"
        end
      end
    end

    # < vector >

    def set_unit_vect_options(options)
      DCLExt.set_unit_vect_options(options)
    end
    def next_unit_vect_options(options)
      DCLExt.next_unit_vect_options(options)
    end

    @@vxfxratio=nil    # for flow_vect
    @@vyfyratio=nil    # for flow_vect
    @@vfratio=nil      # for flow_vect_anyproj
    @@flenmax=nil      # for flow_vect_anyproj

    @@vector_options = Misc::KeywordOptAutoHelp.new(
      ['index', nil, 'Line index of vectors.'],
      ['title', nil, 'Title of the figure(if nil, internally determined)'],
      ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
      ['map_axes', false, '[USE IT ONLY WHEN itr=10 (cylindrical)] If true, draws axes by temprarilly switching to itr=1 and calling GGraph::axes.'],
      ['flow_vect', true, 'If true, use DCLExt::flow_vect to draw vectors; otherwise, DCL::ugvect is used.'],
      ['flow_vect_anyproj', nil, 'Whether to use flow_vect_anyproj. If nil, up to the current projection number (when >=2); if true, always; if false, never. (precedence if higher than the flow_vect parameter)'],
      ['keep', false, 'Use the same vector scaling as in the previous call. -- Currently, works only when "flow_vect" is true'],
      ['factor', 1.0, '(Effective only if flow_vect) scaling factor to strech/reduce the arrow lengths'],
      ['unit_vect', false, 'Show the unit vector'],
      ['max_unit_vect', false, '(Effective only if flow_vect && unit_vect) If true, use the maximum arrows to scale the unit vector; otherwise, normalize in V coordinate.'],
      ['ux_unit', nil, '(If Numeric) length of the x direction unit vector (precedence of this option is lower than max_unit_vect)'],
      ['uy_unit', nil, '(If Numeric) length of the y direction unit vector (precedence of this option is lower than max_unit_vect)'],
      ['len_unit', nil, '(Effective only when flow_vect_anyproj is used) If Numeric, length of the the unit vector in terms of (fx,fy); if nil (defualt), the unitvecto length is set to be the maximum one'],
      ['flow_itr5', false, 'If true, use DclExt::flow_itr5 to draw vectors on 2-dim polar coordinate. Should be set DCL.sgstrn(5)'],
      ['polar_thinning', nil, '(Effective only when flow_vect_anyproj is used) If Numeric, specifies the maximum grid isotrpy, with which thinning is made near the poles (recommended value: 0.3 ~ 1)'],
      ['distvect_map', true, '(effective only for flow_vect_anyproj when map projection) by default (true) it is assumed that the vector (fx,fy) is based on lengths (such as wind velocities in m/s and fluxes in which wind velocities are incorporated [q*u, q*v]); set it to false if the vector is based on angles (such as the time derivatives of longitude and latitude).'],
       @@data_prep_options
    )

    def vector(fx, fy, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true or false"
      end
      opts = @@vector_options.interpret(options)
      xax, yax, closer, fx, fy = data_prep_2D([fx,fy], newframe, opts)
      if newframe
        fig(xax, yax)
      end
      if newframe
        axes_or_map_and_ttl(fx, opts, xax, yax, fy)
      end
      itr = current_itr
      xaxv = xax.val
      yaxv = yax.val
      DCL.uwsgxa(xaxv)
      DCL.uwsgya(yaxv)

      oldindex = DCLExt.ug_set_params("index" => opts['index']) if opts['index']

      if opts['flow_itr5']
        if itr_is?(5)
          DCLExt.flow_itr5( fx, fy, opts['factor'], opts['unit_vect'] )
        else
          raise "flow_itr5 option should use with itr=5."
        end
      elsif opts['flow_vect_anyproj'] ||
            ( opts['flow_vect_anyproj'].nil? && opts['flow_vect'] && itr >=2 )
        @@vfratio, @@flenmax = 
            DCLExt.flow_vect_anyproj(fx.val, fy.val, xaxv, yaxv, 
                                     opts['factor'], 1, 1, opts['distvect_map'],
                                     (opts['keep'] && @@vfratio),
                                     (opts['keep'] && @@flenmax),
                                     opts['polar_thinning'] )
        if opts['unit_vect']
          len_unit = opts['len_unit'] || @@flenmax
          DCLExt.unit_vect_single(@@vfratio, len_unit)
        end
      elsif opts['flow_vect']
        uninfo = DCLExt.flow_vect(fx.val, fy.val, opts['factor'], 1, 1,
                  (opts['keep']&& @@vxfxratio), (opts['keep'] && @@vyfyratio) )
        @@vxfxratio, @@vyfyratio, = uninfo
        if opts['unit_vect']
          unless opts['max_unit_vect']
            uninfo[2] = opts['ux_unit']  # nil or a Numeric to specify the len 
            uninfo[3] = opts['uy_unit']  # nil or a Numeric to specify the len 
          end
          DCLExt.unit_vect(*uninfo)
        end
      else
        before=DCLExt.ug_set_params({'lunit'=>true}) if opts['unit_vect']
        DCL.ugvect(fx.val, fy.val)
        DCLExt.ug_set_params(before) if opts['unit_vect']
      end
      DCLExt.ug_set_params(oldindex) if opts['index']
      closer.call if closer
      nil
    end

    @@regression_line_options = Misc::KeywordOptAutoHelp.new(
      ['x_given_y', false, 'If false (default), regress y for given x. If true, x given y.'],
      ['annot_slope', nil, 'Whether to show the slope on the right margin. nil: show when itr=1,4, do not show when itr=2,3; true: show; false: not show'],
      ['annot_intercept', false, '[Meaningful only when itr=1 (linear scaling plot)] if true, show the intercept on the right margin'],
      ['limit', false, 'If true, regression line is shown only over the range between max and min of the independent variable. If false, regression line is written over the whole range of the independent variable'],
      ['clip', true, "If true, use DCL's clipping not to show the line outside the viewport"],
      ['index', 1, 'line index'],
      ['type', 1, 'line type']
    )

    def set_regression_line(options)
      @@regression_line_options.set(options)
    end
    @@next_regression_line = nil
    def next_regression_line(options)
      if options.is_a?(Hash)
        @@next_regression_line = options
      else
        raise TypeError,"Hash expected"
      end
      nil
    end

    def regression_line(x,y, options=nil)
      if @@next_regression_line
        options = ( options ? @@next_regression_line.update(options) : @@next_regression_line )
        @@next_regression_line = nil
      end
      opts = @@regression_line_options.interpret(options)

      x = x.val if x.respond_to?(:val)  # GPhys or VArray like
      y = y.val if y.respond_to?(:val)  # GPhys or VArray like
      x = NArray.to_na(x) if x.is_a?(Array)
      y = NArray.to_na(y) if y.is_a?(Array)
       

      xs = x   # scaled x:  x or log(x)  (see below)
      ys = y   # scaled y:  y or log(y)  (see below)

      xlog = ylog = false  # can be overwritten below
      itr = current_itr()
      case itr
      when 1
        # nothing to do
      when 2
        ys = NMMath.log(ys)
        ylog = true
      when 3
        xs = NMMath.log(xs)
        xlog = true
      when 4
        xs = NMMath.log(xs)
        ys = NMMath.log(ys)
        xlog = ylog = true
      else
        raise "Drawing a linear regression line is limited to itr = 1~4 (linear or log plots), while the current itr is #{itr}. (itr is a coordinate transformation parameter set by fig (or set_fig or next_fig).)"
      end

      y_given_x = !opts['x_given_y']

      xr = NArray.sfloat(2)  # --> x ends of the regression line
      yr = NArray.sfloat(2)  # --> y ends of the regression line
      if y_given_x
        a,b = linear_regression(xs,ys)
        if opts["limit"]
          xr[0] = x.min
          xr[1] = x.max
        else
          xr[0],xr[1], = DCL.sgqwnd
        end
        xrs = !xlog ? xr : NMath::log(xr)
        yrs = a + b*xrs
        yr = !ylog ? yrs : NMath::exp(yrs)
      else
        a,b = linear_regression(ys,xs)
        if opts["limit"]
          yr[0] = y.min
          yr[1] = y.max
        else
          dum0,dum1, yr[0], yr[1] = DCL.sgqwnd
        end
        yrs = !ylog ? yr : Math::log(yr)
        xrs = a + b*yrs
        xr = !xlog ? xrs : Math::exp(xrs)
      end

      before = DCLExt.sg_set_params({'lclip'=>opts['clip']})
      DCL.sgplzu(xr,yr,opts["type"],opts["index"]) 
      DCLExt.sg_set_params(before)

      ai = opts['annot_intercept'] || opts['annot_intercept'].nil? && itr==1
      as = opts['annot_slope'] || opts['annot_slope'].nil? && (itr==1 or itr==4)
      if as && ai 
        if y_given_x
          annot = ["regr  y=a+bx:", 
                   "  a=#{DCL.chval('A',a)}", "  b=#{DCL.chval('A',b)}"]
        else
          annot = ["regr  x=a+by:", 
                   "  a=#{DCL.chval('A',a)}", "  b=#{DCL.chval('A',b)}"]
        end
        annotate(annot, @@nannot)
      elsif as  
        if y_given_x
          annot = ["slope: #{DCL.chval('A',b)}"]
        else
          annot = ["regress x given y:", " x(y) slope: #{DCL.chval('A',b)}"]
        end
        annotate(annot, @@nannot)
      end

      [a,b]
    end
  end

  def linear_regression(x,y)
    cxy, ndiv = NMMath.covariance(x,y)
    cxx, ndiv = NMMath.covariance(x,x)
    mx = x.mean
    my = y.mean
    b = cxy/cxx
    a = my - b*mx
    [a,b]
  end

  def linear_reg_slope_error(x,y,a,b)
    if x.respond_to?(:count_sum)
      n = x.count_sum
    else
      n = x.size
    end
    raise("data length (#{n}) must be greater than 2") if n<=2
    dy = y - (a + b*x)
    sig2y = (dy*dy).sum / (n-2)  # \sig_y^2    : Taylor (8.15)
    xe = x - x.mean
    delta_n = (xe*xe).sum        # \Delta / N  : Taylor (8.12)
    err = NMMath.sqrt( sig2y / delta_n )       # Taylor (8.17)
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
  DCL.slmgn(0.0, 0.0, 0.011, 0.0)
  DCL.slsttl("#PAGE","b",1.0,1.0,0.01,1)
  DCL.sldiv('y',2,2)
  #DCL.sgpset('lcntl', false)
  DCL.sgpset('isub', 96)      # control character of subscription: '_' --> '`'
  DCL.sgpset('lfull',true)
  DCL.sgpset('lfprop',true)
  DCL.uzfact(0.9)

#=begin
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
    print "** GGraph::vector options **\n"
    GGraph.vector(gp_dummy,gp_dummy,true,'help'=>true)
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

  begin
    print "** GGraph::tone options **\n"
    GGraph.tone(gp_dummy,true,'help'=>true)
  rescue
  end

  begin
    print "** GGraph::regression_line options **\n"
    GGraph.regression_line(nil,nil,"help"=>true)
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

  #/ graph 34/
  GGraph.next_fig('itr'=>5)
  GGraph.tone(gp_velrad,true)
  GGraph.vector(gp_velrad, gp_vellat, false,
                'flow_itr5'=>true,'factor'=>1e-1)
  GGraph.color_bar

  #/ graph 35/
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

  #/ graph 36/
  GGraph.next_fig('itr'=>5)
  GGraph.vector(gp_velrad, gp_vellon, true,
                'flow_itr5'=>true,'factor'=>1e-1)

  GGraph.next_fig('itr'=>5)
  GGraph.tone(gp_velrad,true)
  GGraph.vector(gp_velrad, gp_vellon, false,
                'flow_itr5'=>true,'factor'=>1e-1)
  GGraph.color_bar


#=end

  #### AssocCoordinates #####

  DCL.sgpset('lfull',false)
  DCL.uzfact(1.5)

  nx = 20
  ny = 15
  nz = 2
  x = (NArray.sfloat(nx).indgen! + 0.5) * (2*Math::PI/nx)
  y = NArray.sfloat(ny).indgen! * (2*Math::PI/(ny-1))
  z = NArray.sfloat(nz).indgen! 
  vx = VArray.new( x ).rename("x")
  vy = VArray.new( y ).rename("y")
  vz = VArray.new( z ).rename("z")
  xax = Axis.new().set_pos(vx)
  yax = Axis.new().set_pos(vy)
  zax = Axis.new().set_pos(vz)
  xygrid = Grid.new(xax, yax)
  xyzgrid = Grid.new(xax, yax, zax)

  sqrt2 = Math::sqrt(2.0)
  p = NArray.sfloat(nx,ny)
  q = NArray.sfloat(nx,ny)
  for j in 0...ny
    p[true,j] = NArray.sfloat(nx).indgen!(2*j,1)*sqrt2
    q[true,j] = NArray.sfloat(nx).indgen!(2*j,-1)*sqrt2
  end
  vp = VArray.new( p ).rename("p")
  vq = VArray.new( q ).rename("q")
  gp = GPhys.new(xygrid, vp) 
  gq = GPhys.new(xygrid, vq) 
  r = NArray.sfloat(nz).indgen! * (-2)
  vr = VArray.new( r ).rename("r")
  gr = GPhys.new( Grid.new(zax), vr ) 

  d = NMath::sin(x.newdim(1,1)) * NMath::cos(y.newdim(0,1)) + z.newdim(0,0)
  vd = VArray.new( d ).rename("d")
  gd = GPhys.new(xyzgrid, vd)
  gd.set_assoc_coords([gp,gq,gr])


  GGraph.set_fig('itr'=>1,'viewport'=>[0.17,0.85,0.17,0.85])
  GGraph.tone(gd,true)
  GGraph.color_bar
  GGraph.tone(gd,true, 'xcoord'=>"p",'ycoord'=>"q")
  GGraph.contour(gd,false, 'xcoord'=>"p",'ycoord'=>"q")
  GGraph.color_bar
  GGraph.tone(gd,true, 'ycoord'=>"p")
  GGraph.contour(gd,false, 'ycoord'=>"p")
  GGraph.color_bar

  begin
    require 'numru/gphys_ext'
    GGraph.tone gd.cut('p'=>30..50,'q'=>-10..10),true,
           'xcoord'=>"p",'ycoord'=>"q"
    GGraph.color_bar

    DCL.sgpset('lclip',true)
    GGraph.next_fig('window'=>[30,50,-10,10] )
    GGraph.tone( gd.cut('p'=>30..50,'q'=>-10..10),true,
                 'xcoord'=>"p",'ycoord'=>"q" )
    GGraph.color_bar

    GGraph.tone(gd.cut('p'=>10..50,'x'=>2..5),true, 'ycoord'=>"p")
    GGraph.contour(gd,false, 'ycoord'=>"p")

    GGraph.tone(gd[1,true,true],true)
    GGraph.color_bar
    GGraph.tone(gd[1,true,true],true,'ycoord'=>"r")
    GGraph.color_bar
    DCL.sgpset('lclip',false)
  rescue
    print "\n** skipped graphics that require numru/gphys_ext **\n\n"
  end

  DCL.uzfact(1/1.5)

  #/ graph 45 /
  GGraph.set_fig('viewport'=>[0.2,0.8,0.2,0.8])
  GGraph.tone(gphys, true, "auto"=>true, "auto"=>true)
  GGraph.contour(gphys, false)
  GGraph.color_bar


  #/ graph 46 /

  file = '../../testdata/UV.jan.nc'
  u = GPhys::NetCDF_IO.open(file, 'U')
  v = GPhys::NetCDF_IO.open(file, 'V')

  GGraph.scatter(u.cut("level"=>200),v.cut("level"=>200),true,
                 "title"=>"sample scatter plot of multi-D data")

  #/ graph 47 /
  r,n =  GGraph.scatter(u.cut("lat"=>40,"level"=>200),v.cut("lat"=>40,"level"=>200),
                        true,'correlation'=>true)
  puts "correlation = #{r}, num of samples = #{n}"

  #/ graph 48 /
  x = u.cut("level"=>850)
  y = v.cut("level"=>850)
  z = (x**2 + y**2).sqrt
  z.long_name = "wind speed"
  GGraph.color_scatter(x,y,z)
  GGraph.color_bar

  #/ graph 49 /
  x = u.cut("lat"=>40,"level"=>200)
  y = v.cut("lat"=>40,"level"=>200)
  GGraph.next_fig("window"=>[10,50,-20,20])
  GGraph.scatter(x,y,true,'correlation'=>true)
  require "numru/ganalysis/eof" 
  eof,rate = GAnalysis.eof2(x,y)
  mean = [x.mean.val,y.mean.val]
  GGraph::add_mode_vectors(mean,eof,
                        "style"=>"line","lineindex"=>21,"linetype"=>1,"fact"=>2)
  GGraph::add_mode_vectors(mean,eof,
                        "style"=>"arrow","lineindex"=>33,"linetype"=>1,"fact"=>1)
  GGraph::add_mode_vectors(mean,eof,
                        "style"=>"ellipse","lineindex"=>41,"linetype"=>3,"fact"=>1.5)
  #/ graph 50 /
  DCL.sgpset('lfull',false)
  x = u.cut("lat"=>40,"level"=>200)
  y = v.cut("lat"=>40,"level"=>200)
  xv = x.val
  yv = y.val
  xx = x.val.to_na  # NArrayMiss 1.2.1より上に更新後に消して xx は x に変えるべし
  yy = y.val.to_na  # NArrayMiss 1.2.1より上に更新後に消して yy は y に変えるべし

  GGraph.next_fig("window"=>[xv.min.floor-5, xv.max.ceil+5, 
                             yv.min.floor-3, yv.max.ceil+3])
  GGraph.scatter(x,y, true, "title"=>"regression y given x; with limit option",
                            'correlation'=>true)
  a, b = GGraph.regression_line(xx,yy,"limit"=>true) 
  print "** Graph 50\n  regression coefficients a=#{a} b=#{b}\n"

  #/ graph 51 /
  GGraph.next_fig("window"=>[xv.min.floor-5, xv.max.ceil+5, 
                             yv.min.floor-3, yv.max.ceil+3])
  GGraph.scatter(x,y, true, "title"=>"regression x given y; with full annotation")
  a, b = GGraph.regression_line(xx,yy,"x_given_y"=>true,
                                "type"=>2,"index"=>3,
                                "annot_intercept"=>true)
  print "** Graph 51\n  regression coefficients a=#{a} b=#{b}\n"

  #/ graph 52 /
  x = x.abs**2
  y = y.abs**2 + x*0.1
  xx = x.val.to_na  # NArrayMiss 1.2.1より上に更新後に消して xx は x に変えるべし
  yy = y.val.to_na  # NArrayMiss 1.2.1より上に更新後に消して yy は y に変えるべし

  GGraph.next_fig("itr"=>4)
  GGraph.scatter(x,y, true, "title"=>"x given y; log scaling")
  GGraph.regression_line(xx,yy)

  #/ graph 53 /
  GGraph.next_fig("itr"=>2)
  GGraph.scatter(x,y, true, "title"=>"x given y; x-linear y-log")
  GGraph.regression_line(xx,yy)

  #/ graph 54 /
  GGraph.set_fig('viewport'=>[0.1,0.84,0.2,0.8])
  DCL.uzfact(1.5)

  GGraph.vector(gphys+10,gphys-10,true,
        {'unit_vect'=>true, 'ux_unit'=>70,'uy_unit'=>70, 
         'xintv'=>2, 'yintv'=>2})

  #/ graph 55 /
  GGraph.vector(gphys+10,gphys-10,true,
        {'unit_vect'=>true, 'ux_unit'=>70, 'xintv'=>2, 'yintv'=>2})

  #/ graph 56 /

  DCL.sgpset('lfull',true)
  GGraph.set_fig('itr'=>1,'viewport'=>[0.08,0.82,0.23,0.57])
  GGraph.vector(u.cut("level"=>200),v.cut("level"=>200),true,
                'unit_vect'=>true)

  #/ graph 57 /

  DCL.sgpset('lfull',true)
  GGraph.set_fig('itr'=>2,'viewport'=>[0.2,0.8,0.2,0.6])
  GGraph.vector(u[0,false],v[0,false]*10,true,
                'unit_vect'=>true)

  #/ graph 58 /

  GGraph.set_fig('itr'=>10)
  GGraph.set_map('coast_world'=>true)
  GGraph.vector(u.cut("level"=>200),v.cut("level"=>200),true,
                'unit_vect'=>true,'flow_vect_anyproj'=>true,"factor"=>1.5)

  #/ graph 59 /
  GGraph.set_fig('itr'=>30,'viewport'=>[0.2,0.7,0.1,0.6])
  GGraph.vector(u.cut("lat"=>20..90,"level"=>200),
                v.cut("lat"=>20..90,"level"=>200),true,
                'unit_vect'=>true)

  #/ graph 60 /
  GGraph.set_fig('itr'=>12,'viewport'=>[0.1,0.8,0.15,0.55])
  DCLExt.next_unit_vect_options('rsizet'=>0.03,'vertical'=>false,"vxuloc"=>0.45)
  GGraph.vector(u.cut("level"=>200),
                v.cut("level"=>200),true,
                'unit_vect'=>true,"len_unit"=>70)

  #/ graph 61/
  GGraph.next_fig('itr'=>14)
  GGraph.next_map('fill'=>true)
  GGraph.tone(gphys, true)
  GGraph.color_bar
  GGraph.contour(gphys, false) # contour after color_bar

  #/ graph 67/
  GGraph.next_fig('itr'=>23)
  GGraph.next_map('fill'=>true)
  GGraph.tone_and_contour(gphys, true, 'color_bar'=>true)

  #/ graph 69/
  GGraph.next_fig('itr'=>31,'viewport'=>[0.22,0.78,0.06,0.6])
  GGraph.next_map('fill'=>true)
  DCL.sgpset('lclip',true)
  GGraph.tone(gphys, true)
  GGraph.color_bar
  GGraph.contour(gphys, false) # contour after color_bar
  DCL.sgpset('lclip',false)

  #/ graph 71/
  GGraph.next_fig('itr'=>10)
  GGraph.next_map('fill'=>true)
  GGraph.next_axes('xtitle'=>'')
  GGraph.tone_and_contour(gphys, true, 'map_axes'=>true, 'color_bar'=>true)

  #/ stair step line plots /
  na = NMath.sin(NArray.sfloat(11).indgen! * 2 * Math::PI / 10)
  va = VArray.new(na, {}, "dummy")
  p gphys = GPhys.new(Grid.new(Axis.new.set_pos(VArray.new(NArray.sfloat(11).indgen!, {}, "x"))), va)
  GGraph.set_fig('itr'=>1, 'viewport' => [0.2, 0.8, 0.15, 0.6])

  GGraph.line(gphys, true, 'index' => 21,'step_plot' => true, 'step_position' => -1)
  GGraph.mark(gphys, false, 'index' => 31, 'type' => 9)

  GGraph.line(gphys, true, 'index' => 21, 'step_plot' => true, 'step_position' =>  0)
  GGraph.mark(gphys, false, 'index' => 31, 'type' => 9)

  GGraph.line(gphys, true, 'index' => 21, 'step_plot' => true, 'step_position' =>  1)
  GGraph.mark(gphys, false, 'index' => 31, 'type' => 9)

  GGraph.line(gphys, true, 'index' => 21, 'step_plot' => true, 'step_position' =>  0, 'exchange' => true)
  GGraph.mark(gphys, false, 'index' => 31, 'type' => 9, 'exchange' => true)

  tmpu = u.cut("lon" => 0..180, "lat" => 20..90, "level" => 200)
  tmpv = v.cut("lon" => 0..180, "lat" => 20..90, "level" => 200)
  #/ test for ugvect with 'keep' option /
  GGraph.set_fig('itr' => 1, 'viewport' => [0.2, 0.7, 0.3, 0.6])
  GGraph.vector(tmpu, tmpv, true, 'unit_vect' => true, 'index' => 23)
  DCL::uxsttl("B", "Red: original speed", 0)
  GGraph.vector(tmpu * 0.5, tmpv * 0.5, true, 'unit_vect' => true, 'index' => 33, 'keep' => true)
  DCL::uxsttl("B", "Green: half speed with 'keep=T'", 0)

  #/ test for flow_vect with 'keep' option /
  GGraph.set_fig('itr' => 1, 'viewport' => [0.2, 0.7, 0.3, 0.6])
  GGraph.vector(tmpu, tmpv, true, 'unit_vect' => true, 'flow_vect' => true, 'index' => 23)
  DCL::uxsttl("B", "Red: original speed (flow_vect)", 0)
  GGraph.vector(tmpu * 0.5, tmpv * 0.5, true, 'unit_vect' => true, 'flow_vect' => true, 'index' => 33, 'keep' => true)
  DCL::uxsttl("B", "Green: half speed with 'keep=T'", 0)

  #/ test for flow_vect_anyproj with 'keep' option /
  GGraph.set_fig('itr' => 10, 'viewport' => [0.2, 0.7, 0.1, 0.6])
  GGraph.vector(tmpu, tmpv, true,  'unit_vect' => true, 'index' => 23)
  DCL::uxsttl("B", "Red: original speed", 0)
  GGraph.vector(tmpu * 0.5, tmpv * 0.5, true,  'unit_vect' => true, 'index' => 33, 'keep' => true)
  DCL::uxsttl("B", "Green: half speed with 'keep=T'", 0)

  GGraph.set_fig('itr' => 30, 'viewport' => [0.2, 0.7, 0.1, 0.6])
  GGraph.vector(u.cut("lat" => 20..90, "level" => 200),
                v.cut("lat" => 20..90, "level" => 200), true,
                'unit_vect' => true, 'index' => 23)
  DCL::uxsttl("B", "Red: original speed", 0)
  GGraph.vector(u.cut("lat" => 20..90, "level" => 200) * 0.5,
                v.cut("lat" => 20..90, "level" => 200) * 0.5, true,
                'unit_vect' => true, 'index' => 33, 'keep' => true)
  DCL::uxsttl("B", "Green: half speed with 'keep=T'", 0)


  ############
  DCL.grcls

end
