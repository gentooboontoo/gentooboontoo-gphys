require "numru/dcl"
require "numru/misc"
require "date"      # needs ruby >= 1.8 for DateTime class
require "narray_miss"

############################################################

=begin
=module NumRu::DCLExt

An extension of RubyDCL.

==Index

Original methods
  * ((<lon_ax>))
    Draw longitude axis. (label format: degrees + 'E' or 'W')
  * ((<lat_ax>))
    Draw latitude axis. (label format: degrees + 'N' or 'S')
  * ((<unit_vect>)) Show the "unit vector", which indicate the vector scaling.
  * ((<unit_vect_single>)) Draw a unit vector (only one arrow is drawn).
  * ((<set_unit_vect_options>))
    Change the default option values for ((<unit_vect>)).
  * ((<next_unit_vect_options>))
    Set the option values effective only in the next call of ((<unit_vect>))
  * ((<flow_vect>)) 2D Vector plot. Unlike (({DCL::ugvect})), scaling are made in term of the physical (or "U") coordinate.
  * ((<flow_vect_anyproj>)) flow_vect available in any coordinate projections
  * ((<flow_itr5>)) 2D Vector plot on the 2-dim polar coodinate.
  * ((<color_bar>)) Color Bar
  * ((<set_color_bar_options>))
  * ((<legend>)) 
    Annotates line/mark type and index (and size if mark).
  * ((<quasi_log_levels_z>)) 
    Driver of quasi_log_levels with data values
  * ((<quasi_log_levels>)) 
    Returns approximately log-scaled contour/tone levels.

MATH1
* ((<glpack>))
  * ((<gl_set_params>))
    Calls (({DCL.glpset})) multiple times (for each key and val of (({hash}))).
GRPH1
* ((<sgpack>))
  * ((<sg_set_params>))
    Calls (({DCL.sgpset})) multiple times (for each key and val of (({hash}))).
* ((<slpack>))
  * ((<sl_set_params>))
    Calls (({DCL.slpset})) multiple times (for each key and val of (({hash}))).
* ((<swpack>))
  * ((<sw_set_params>))
    Calls (({DCL.swpset})) multiple times (for each key and val of (({hash}))).
GRPH2
* ((<uzpack>))
  * ((<uz_set_params>))
    Calls (({DCL.uzpset})) multiple times (for each key and val of (({hash}))).
* ((<ulpack>))
  * ((<ul_set_params>))
    Calls (({DCL.ulpset})) multiple times (for each key and val of (({hash}))).
* ((<ucpack>))
  * ((<uc_set_params>))
    Calls (({DCL.ucpset})) multiple times (for each key and val of (({hash}))).
* ((<uupack>))
  * ((<uu_set_params>))
    Calls (({DCL.uupset})) multiple times (for each key and val of (({hash}))).
* ((<uspack>))
  * ((<us_set_params>))
    Calls (({DCL.uspset})) multiple times (for each key and val of (({hash}))).
* ((<udpack>))
  * ((<ud_set_params>))
    Calls (({DCL.udpset})) multiple times (for each key and val of (({hash}))).
  * ((<ud_set_linear_levs>))
    Set contour levels with a constant interval
  * ((<ud_set_contour>))
    Set contours of at specified levels.
  * ((<ud_add_contour>))
    Same as ((<ud_set_contour>)), but does not clear the contour levels that have
    been set.
* ((<uepack>))
  * ((<ue_set_params>))
    Calls (({DCL.uepset})) multiple times (for each key and val of (({hash}))).
  * ((<ue_set_linear_levs>))
    Set tone levels with a constant interval
  * ((<ue_set_tone>))
    Set tone levels and patterns.
  * ((<ue_add_tone>))
    Same as ((<ue_set_tone>)), but does not clear the tone levels that have
    been set.
* ((<ugpack>))
  * ((<ug_set_params>))
    Calls (({DCL.ugpset})) multiple times (for each key and val of (({hash}))).
    See ((<gl_set_params>)) for usage.
* ((<umpack>))
  * ((<um_set_params>))
    Calls (({DCL.umpset})) multiple times (for each key and val of (({hash}))).



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

===Date and time axes

---datetime_ax(date_from, date_to, options=nil)
    Draw axes with date and hours. 
    The DCL window must have been defined in the units "days"
    and to start with 0 (regarding the direction to draw the axis).

    ARGUMENTS
    * date_from (DateTime) : date&time to beggin
    * date_to (DateTime) : date&time to end
    * options (Hash) : options to change the default behavior if specified:
       option name   default value   # description:
       'yax'         false   # true => y-axis, false => x-axis  
       'cside'       nil     # "b", "t", "l", "r", nil (=>left/bottom), 
                             # or false (=>right/top)'  
       'dtick1'      1       # small tick interval in hours
       'dtick2'      nil     # large tick (with hour labels) interval in hours
       'year'        false   # true => add year to date label
       'month'       true    # true => add month to date label

---date_ax(date_from, date_to, options=nil)
    Similar to ((<datetime_ax>)) but 
    draws a calendar axis in terms of date (not hours).
    This method uses DCL's UCPACK (DCL.uc[xy]acl) when appropritate;
    i.e., when the period is short enough (typically with in a few
    years) so that year labels are written. Unfortunately,
    the current uc[xy]acl (or uc[xy]yr) suppress year labels
    when the period is long to write year albels for each year.
    In such a case, this method uses DCLExt.year_ax.
    Note that future uc[xy]acl may cover all the situation,
    so this method will not be needed.

    ARGUMENTS
    * date_from (DateTime) : date&time to beggin
    * date_to (DateTime) : date&time to end
    * options (Hash) : options to change the default behavior if specified:
      option name        default value        # description:
      "yax"         false   # true => y-axis, false => x-axis
      "cside"         nil   # "b", "t", "l", "r", nil (=>left/bottom), or false
                            # (=>right/top)
      "margin_factor"  0.9  # Factor to control the extent to use
                            # UCPACK; The smaller, the less, requiring more
                            # space between year labels
      "dtick1"        nil   # (For long time series) small tick interval
                            # (years)
      "dtick2"        nil   # (For long time series) large tick with year
                            # labels (years)
      "help"        false   # show help message if true

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
       "vertical"    true    # (used only in unit_vect_single) the unit vector
                             # is directed upward if true, to the right if not.

---unit_vect_single(vfratio, flen, options=nil )
    Draw a unit vector (only one arrow is drawn). Suitable to called after ((<flow_vect_anyproj>)).

    ARGUMENTS
    * vfratio (Numeric) : see ((<flow_vect_anyproj>)).
    * flen (Numeric) : length of the unit vector
    * options (Hash) : see ((<unit_vect>)).

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

---flow_vect_anyproj(fx, fy, xg, yg, factor=1.0, xintv=1, yintv=1, distvect_map=true, vfratio=nil)

    flow_vect that can be used under any of the projections supported by DCL.
    Arrows drawn by this method have lengths proportional to sqrt(fx**2+fy**2),
    and their directions are properly directed locally (consistent with the
    local coordinate). A special treatment
    is made for map projections if distvect_map==true (see below). Singular 
    points of the projection is heuristically handled (see the source code
    for details).

    ARGUMENTS
    * fx, fy [2D NArray or NArrayMiss] : the vector field.
    * xg, yg [1D (or 2D) NArray] : the grid points
    * factor (Integer) : factor to change the arrow length.
      By default, arrows are scaled so that the longest one
      matches the typical grid interval.
    * xintv, yintv (Integer) : interval to thin out (({fx})) and (({fy})),
      respectively. Useful if the grid points are too many.
    * distvect_map [true/false] : (effective only for map projections)
      by default (true) it is assumed that the vector (fx,fy) is based 
      on lengths (such as wind velocities in m/s,
      and fluxes in which wind velocities are incorporated [q*u, q*v]);
      set it to false if the vector is based on angles
      (such as the time derivatives of longitude and latitude).
      When true, a directional correction is made to match the scaling of
      DCL's window, which is based on angles (longitude and latitude).
    * vfratio [nil or Numeric] : if Numeric, specifies the ratio
      between the lengths of vectors in the V coordinate and the actual
      length (sqrt(fx**2+fy**2)). Good to unify the scaling over multiple
      plots

    RETURN VALUE
    * [ vfratio, flenmax ] : 
     * vfratio : see above
     * flenmax : maximum of sqrt(fx**2+fy**2)

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
       "inffact"     2.25    # factor to change the length of triangle on the
                             # side for infinity (relative to 'vwidth')
       "landscape"   false   # if true, horizonlly long (along x axes)
       "portrait"    true    # if true, vertically long (along y axes)
       "top"         false   # place the bar at the top (effective if
                             # landscape)
       "left"        false   # place the bar in the left (effective if
                             # portrait)
       "units"       nil     # units of the axis of the color bar
       "units_voff"  0.0     # offset value for units from the default position
                             # in the V coordinate (only for 'units' != nil)
       "title"       nil     # title of the color bar
       "title_voff"  0.0     # offset value for title from the default position
                             # in the V coordinate (only for 'title' != nil)
       "tickintv"    1       # 0,1,2,3,.. to specify how frequently the
                             # dividing tick lines are drawn (0: no tick lines,
                             # 1: every time, 2: ever other:,...)
       "labelintv"   nil     # 0,1,2,3,.. to specify how frequently labels are
                             # drawn (0: no labels, 1: every time, 2: ever
                             # other:,... default: internally determined)
       "labels_ud"   nil     # user-defined labels for replacing the default
                             # labels (Array of String)
       "charfact"    0.9     # factor to change the label/units/title character
                             # size (relative to 'rsizel1')
       "log"         false   # set the color bar scale to logarithmic
       "constwidth"  false   # if true, each color is drawn with the same width
       "index"       nil     # line index of tick lines and bar frame
       "charindex"   nil     # line index of labels, units, and title
       "chval_fmt"   nil     # string to specify the DCL.chval format for
                             # labeling
       "help"        false   # show help message if true

===Others
---legend(str, type, index, line=false, size=nil, vx=nil, dx=nil, vy=nil, first=true, mark_size=nil)

Annotates line/mark type and index (and size if mark).
By default it is shown in the right margin of the viewport.
    
* str is a String to show
* line: true->line ; false->mark
* vx: vx of the left-hand point of legend line (or mark position).
    * nil : internally determined
    * Float && > 0 : set explicitly
    * Float && < 0 : move it relatively to the left from the default
* dx: length of the legend line (not used if mark).
    * nil : internally determined
    * Float && > 0 : set explicitly
* vy: vy of the legend (not used if !first -- see below).
    * nil : internally determined
    * Float && > 0 : set explicitly
    * Float && < 0 : move it relatively lower from the default
* first : if false, vy is moved lower relatively from the previous vy.
* mark_size : size of the mark. if nil, size is used.

---quasi_log_levels_z(vals, nlev=nil, max=nil, min=nil, cycle=1)

Driver of quasi_log_levels with data values

---quasi_log_levels(lev0, lev1, cycle=1)

Returns approximately log-scaled contour/tone levels as well as
major/minor flags for contours. No DCL call is made in here.

* cycle (Integer; 1, or 2 or 3) : number of level in one-order.
  e.g. 1,10,100,.. for cycle==1; 1,3,10,30,.. for cycle==2;
  1,2,5,10,20,50,.. for cycle==3
* lev0, lev1 (Float) : levels are set between this two params
  * if lev0 & lev1 > 0 : positive only
  * if lev0 & lev1 < 0 : negative only
  * if lev0 * lev1 < 0 : both positive and negative
    (usig +-[lev0.abs,lev1.abs])
RETURN VALUE:
* [ levels, mjmn ]

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
      options ||= @@empty_hash
      raise TypeError, "options must be a Hash" if !options.is_a?(Hash)
      min = options['min']
      max = options['max']
      nlev = options['nlev']
      interval = options['interval']
      nozero = options['nozero']
      dx = interval || (nlev ? -nlev : 0)
      if min || max
        min ||= v.min
        max ||= v.max
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
      dx = interval || (nlev ? -nlev : 0)
      if min || max
        min ||= v.min
        max ||= v.max
        DCL.uegtla(min, max, dx)
      else
        v = v.reshape(v.length,1) if v.rank==1
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

    # <<< Date and time axes (moved from dclext_datetime_ax.rb) >>>

    @@datetime_ax_options = Misc::KeywordOptAutoHelp.new(
      ['yax', false, 'true => y-axis, false => x-axis'],
      ['cside', nil, '"b", "t", "l", "r", nil (=>left/bottom), or false (=>right/top)'],
      ['dtick1', 1, 'small tick interval in hours'],
      ['dtick2', nil, 'large tick (with hour labels) interval in hours'],
      ['year', false, 'true => add year to date label'],
      ['month', true, 'true => add month to date label']
    )

    def datetime_ax(date_from, date_to, options=nil)
      # date_from [a DateTime] : start on this date&time
      # date_to [a DateTime]   : end on this date&time

      opt = @@datetime_ax_options.interpret(options)

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

      if opt['year']
	datefmt = '%Y/%m/%d'
      elsif opt['month']
	datefmt = '%m/%d'
      else
	datefmt = '%d'
      end

      # < window parameters >

      ux1,ux2,uy1,uy2 = DCL.sgqwnd
      if xax
	u1, u2 = ux1, ux2
      else
	u1, u2 = uy1, uy2
      end

      loffset_save = DCL.uzpget('loffset')
      xyfact_save = DCL.uzpget(xy+'fact')
      xyoffset_save = DCL.uzpget(xy+'offset')

      tu1 = date_from.day_fraction.to_f
      range_day = date_to - date_from    # time btwn start and end (in days)
      tu2 = tu1 + range_day

      # < axis in hours >

      DCL.uzpset('loffset',true)

      DCL.uzpset(xy+'fact',24.0)
      DCL.uzpset(xy+'offset',(tu1-u1)*24)

      dtick1 = opt['dtick1']
      if opt['dtick2']
	dtick2 = opt['dtick2']
      else
	if range_day >= 4
	  dtick2 = 24
	elsif range_day >= 2
	  dtick2 = 12
	elsif range_day >= 1
	  dtick2 = 6
	elsif range_day >= 0.5
	  dtick2 = 3
	elsif range_day >= 0.25
	  dtick2 = 2
	else
	  dtick2 = 1
	end
      end

      str_hour = (tu1*24).ceil
      end_hour = (tu2*24).floor
      tick1=Array.new
      tick2=Array.new
      labels=Array.new
      h1 = str_hour + (-str_hour % dtick1)
      (h1..end_hour).step(dtick1){|i| tick1.push(i)}
      h2 = str_hour + (-str_hour % dtick2)
      (h2..end_hour).step(dtick2) do |i|
	tick2.push(i)
	labels.push((i%24).to_s)
      end
      if xax
	DCL.uxaxlb(cside, tick1, tick2, labels, 2)
      else
	irotl_save = DCL.uzpget('irotly'+cside)
	icent_save = DCL.uzpget('icenty'+cside)
	DCL.uzpset('irotly'+cside,1)
	DCL.uzpset('icenty'+cside,0)
	DCL.uyaxlb(cside, tick1, tick2, labels, 2)
      end

      # < labels in days >

      if DCL.uzpget('label'+xy+cside)
	DCL.uzpset(xy+'fact',1.0)
	DCL.uzpset(xy+'offset',0.0)

	str_day = tu1.floor
	end_day = tu2.floor
	pos=Array.new
	labels=Array.new
	(str_day..end_day).step(1) do |i|
	  u = i.to_f + 0.5 + (u1- tu1)
	  u = (u1+u+0.5)/2 if u < u1
	  u = (u2+u-0.5)/2 if u > u2
	  pos.push(u)
	  str = (date_from+i).strftime(datefmt)
	  str.sub!(/^0/,'') if !opt['year'] && opt['month']
	  labels.push(str)
	end

        if xax
	  DCL.uxsaxz(cside,DCL.uzpget('roffx'+cside))
	  DCL.uxplbl(cside,1,pos,labels,10)
	else
	  DCL.uysaxz(cside,DCL.uzpget('roffy'+cside))
	  DCL.uyplbl(cside,1,pos,labels,10)
	#  DCL.uzpset('irotly'+cside,irotl_save)
	#  DCL.uzpset('icenty'+cside,icent_save)
	end

      end

      if xax
      else
	DCL.uzpset('irotly'+cside,irotl_save)
	DCL.uzpset('icenty'+cside,icent_save)
      end

      # < to finish >

      DCL.uzpset('loffset',loffset_save)
      DCL.uzpset(xy+'fact',xyfact_save)
      DCL.uzpset(xy+'offset',xyoffset_save)

    end

    # <<< Date axes >>>

    @@date_ax_options = Misc::KeywordOptAutoHelp.new(
      ['yax', false, 'true => y-axis, false => x-axis'],
      ['cside', nil, '"b", "t", "l", "r", nil (=>left/bottom), or false (=>right/top)'],
      ['margin_factor', 0.9, 'Factor to control the extent to use UCPACK; The smaller, the less, requiring more space between year labels'],
      ['dtick1', nil, '(For long time series) small tick interval (years)'],
      ['dtick2', nil, '(For long time series) large tick with year labels (years)']
    )

    def date_ax(date_from, date_to, options=nil)
      # < intepret the options >
      opt = @@date_ax_options.interpret(options)

      mfact = opt['margin_factor']

      yax = opt['yax']
      xax = !yax
      if xax
        xy = 'x'
        cside= opt['cside'] || 'b'
      else
        xy = 'y'
        cside= opt['cside'] || 'l'
      end

      # < examine the time period to see wheterh to use UCPACK >
      irot = DCL.uzpget("irotc"+xy+cside)
      rsize = DCL.uzpget("rsizel2")
      nday = date_to - date_from 
      ny = nday / 365.25
      if (xax && irot%2 == 0) || (yax && irot%2 == 1) 
        cw = (rsize*0.82)*4   # approximate width for 4 digits
      else
        cw = rsize
      end
      vx1,vx2,vy1,vy2 = DCL::sgqvpt
      if xax
        vw = (vx2-vx1)/ny
      else
        vw = (vy2-vy1)/ny
      end

      use_ucpack = (cw <= vw*mfact)

      # < draw the axes >
      if use_ucpack
        jd0 = date_from.strftime('%Y%m%d').to_i
        if xax
          DCL.ucxacl(cside,jd0,nday)
        else
          DCL.ucyacl(cside,jd0,nday)
        end
      else
        year_ax(xax, cside, date_from, date_to)
      end

    end

    def year_ax(xax, cside, date_from, date_to)
      y0 = date_from.year
      d0 = date_from.yday
      ry0 = y0 + ( date_from.leap? ? d0/366.0 : d0 / 365.0 )
      y1 = date_to.year
      d1 = date_to.yday
      ry1 = y1 + ( date_to.leap? ? d1/366.0 : d1 / 365.0 )
      if xax
        DCL.uzpset("xoffset",ry0)
        ux0,ux1, = DCL.sgqwnd
        DCL.uzpset("xfact",(ry1-ry0)/(ux1-ux0))
        DCL.usxaxs(cside)
        DCL.uzpset("xoffset",0.0)
        DCL.uzpset("xfact",1.0)
      else
        DCL.uzpset("yoffset",ry0)
        ux0,ux1,uy0,uy1 = DCL.sgqwnd
        DCL.uzpset("yfact",(ry1-ry0)/(uy1-uy0))
        DCL.usyaxs(cside)
        DCL.uzpset("yoffset",0.0)
        DCL.uzpset("yfact",1.0)
      end
    end

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
      xy = (xax ? 'x' : 'y')

      cside = opt['cside']
      cside = (xax ? 'b' : 'l') if cside.nil?
      cside ||= (xax ? 't' : 'r') ### cside is false

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
      x = DCL.irle(umin / dtick1) * dtick1
      x += dtick1 unless DCL.lreq(umin, x)
      u1 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick1*repsl*nn
          x = 0.0
        end
        u1[nn] = x
        nn += 1
        x += dtick1
      end

      # generate numbers for large tickmarks and labels
      nn = 0
      x = DCL.irle(umin / dtick2) * dtick2
      x += dtick2 unless DCL.lreq(umin, x)
      u2 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick2*repsl*nn
          x = 0
        end
        u2[nn] = x
        nn += 1
        x += dtick2
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
      DCL.__send__(xax ? :uxaxlb : :uyaxlb , cside, u1, u2, c2, nc)

      DCL.glpset('lepsl', lepsl) # restore original value
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
      xy = (xax ? 'x' : 'y')

      cside = opt['cside']
      cside = (xax ? 'b' : 'l') if cside.nil?
      cside ||= (xax ? 't' : 'r') ### cside is false

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
      x = DCL.irle(umin / dtick1) * dtick1
      x += dtick1 unless DCL.lreq(umin, x)
      u1 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick1*repsl*nn
          x = 0.0
        end
        u1[nn] = x
        nn += 1
        x += dtick1
      end

      # generate numbers for large tickmarks and labels
      nn = 0
      x = DCL.irle(umin / dtick2) * dtick2
      x += dtick2 unless DCL.lreq(umin, x)
      u2 = []
      while DCL.lrle(x,umax)
        if x.abs < dtick2*repsl*nn
          x = 0
        end
        u2[nn] = x
        nn += 1
        x += dtick2
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
      DCL.__send__(xax ? :uxaxlb : :uyaxlb , cside, u1, u2, c2, nc)

      DCL.glpset('lepsl', lepsl) # restore original value
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
      ['index',  3," Line index of the unit vector"],
      ['vertical', true,"(used only in unit_vect_single) the unit vector is directed upward if true, to the right if not."]
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

    def unit_vect_single(vfratio, flen, options=nil )
      #< options >
      if @@next_unit_vect_options
        options = ( options ? @@next_unit_vect_options.update(options) :
                              @@next_unit_vect_options )
        @@next_unit_vect_options = nil
      end
      opt = @@unit_vect_options.interpret(options)
      vxuloc = opt['vxuloc']
      vyuloc = opt['vyuloc']
      rsizet = opt['rsizet'] || DCL.uzpget('rsizel1')
      index = opt['index']
      vertical = opt['vertical']

      #< show the unit vector and the label >

      if !(vxuloc && vyuloc)
        vx0,vx1,vy0,vy1 = DCL.sgqvpt
        vxuloc = vx1 + opt['vxuoff'] if !vxuloc
        vyuloc = vy0 + opt['vyuoff'] if !vyuloc
      end
      vlen = vfratio * flen
      label = DCL.chval("B",flen)

      lclip_bk = DCLExt.sg_set_params("lclip" => false)
      if vertical
        DCL.sglazv( vxuloc, vyuloc,  vxuloc,      vyuloc+vlen, 1, index )
        DCL.sgtxzv( vxuloc+1.2*rsizet, vyuloc+0.4*vlen,
                    label, rsizet, 90, 0, index)
      else
        DCL.sglazv( vxuloc, vyuloc,  vxuloc+vlen, vyuloc,        1, index )
        DCL.sgtxzv( vxuloc+0.4*vlen, vyuloc-1.2*rsizet,
                    label, rsizet, 0, 0, index)
      end
      DCLExt.sg_set_params(lclip_bk)
      nil
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

    def flow_vect_anyproj(fx, fy, xg, yg,  
                          factor=1.0, xintv=1, yintv=1, 
                          distvect_map=true, vfratio=nil, flenmax=nil, polar_thinning=nil)

      #< parameters to handle singularity of the projection  >

      ddv = 0.3e-3  # Initial value for viewport sampling to find directions.
                    # This parameter is modified below if the round off error
                    # may be severe.
      eps = 0.05  # Allowed maximum inconsistency in two sampling results
      acc = 1e7   # order of mantissa of sfloat
      epsbk = 3e-6  # factor to judge whether a grid point is on the backside
                    # when the projection is multi-valued as map projections

      #< preparation >

      raise ArgumentError,"Expect 2D arrays" if fx.rank != 2 || fy.rank != 2
      raise ArgumentError,"fx.shape != fy.shape" if fx.shape != fy.shape
      raise ArgumentError,"xintv must be a positive integer" if xintv < 0
      raise ArgumentError,"yintv must be a positive integer" if yintv < 0
      nx, ny = fx.shape
      if xg.rank == 1
        raise ArgumentError,"len of xg (#{xg.length}) != #{nx}" if xg.length!=nx
      else
        raise ArgumentError,"xg.shape != shape of data" if xg.shape != fx.shape
      end
      if yg.rank == 1
        raise ArgumentError,"len of yg (#{yg.length}) != #{ny}" if yg.length!=ny
      else
        raise ArgumentError,"yg.shape != shape of data" if yg.shape != fx.shape
      end
      if xintv >= 2
        idx = NArray.int(nx/xintv).indgen!*xintv  # [0,xintv,2*xintv,..]
        fx = fx[idx, true]
        fy = fy[idx, true]
        xg = xg[idx, false]
      end
      if yintv >= 2
        idx = NArray.int(ny/yintv).indgen!*yintv  # [0,yintv,2*yintv,..]
        fx = fx[true, idx]
        fy = fy[true, idx]
        yg = yg[false,idx]
      end
      nx, ny = fx.shape  # again, because of xintv & yintv

      #< read DCL parameters >

      index  = DCL.ugpget('index')
      rsizem = DCL.ugpget('rsizem')
      itype2 = DCL.ugpget('itype2')
      lmissp = DCL.ugpget('lmissp')
      lmiss  = DCL.glpget('lmiss')
      rmiss  = DCL.glpget('rmiss')

      #< Missing value treatment >
      # -- needed to later caluculate flenmax properly

      if lmiss
        fx = NArrayMiss.to_nam(fx, fx.ne(rmiss)) if fx.is_a?(NArray)
        fy = NArrayMiss.to_nam(fy, fy.ne(rmiss)) if fy.is_a?(NArray)
      end

      #< DCL scales >

      wnd = DCL.sgqwnd
      if wnd.include?(DCL.glrget('rundef'))
        ux0,ux1,uy0,uy1 = DCL.sgqtxy
      else
        ux0,ux1,uy0,uy1 = wnd
      end

      flen = Misc::EMath.sqrt( fx*fx + fy*fy )

      if !flenmax
        flenmax = flen.max
      end

      if !vfratio
        vx0,vx1,vy0,vy1 = DCL.sgqvpt
        dvf = Math::sqrt( (vx1-vx0)*(vy1-vy0)/nx/ny )
        vfratio = factor * dvf / flenmax  # factor to get arrow length in V crd
      end 

      #< parameter modification if needed >
      r = [ [ux0.abs, ux1.abs].min / (ux0-ux1).abs, 
            [uy0.abs, uy1.abs].min / (uy0-uy1).abs ].max
      e = acc*ddv*eps
      if ( r > e )
        # ddv is too small for the current window, so the round off error 
        # may be severer. --> increase it up to a prescribed limit.
        ddv = [ r/e*ddv, 0.1 ].min
      end

      #< handling of distance-based vectors under map projection >

      itr = DCL::sgqtrn
      map_proj = ( itr >= 10 and itr <= 40 )
      if map_proj and distvect_map
        cosphi = Misc::EMath.cos( yg * (Math::PI/180.0) )
        umodi = true
      else
        umodi = false
      end

      #< vector drawing >

      if map_proj
        uodr = 360.0   # order of domain size in U coordinate
      else
        uodr = [xg.max, -xg.min, yg.max, -yg.min].max
      end
      dbk = epsbk*uodr

      u = NMatrix.float(2,2)   # NMatrix's index: [column,row]
      ap = NMatrix.float(2,2)
      an = NMatrix.float(2,2)
      for j in 0...ny
        if polar_thinning && xg.rank==1 && yg.rank==1
          j1 = [j+1,ny-1].min
          dy=(yg[j1]-yg[j1-1]).abs
          dx = (xg[1]-xg[0]).abs * cos(yg[j]/180*Math::PI)
          xstep = [ (dy / dx * polar_thinning).round, 1 ].max
        else
          xstep = 1
        end
        (0...nx).step(xstep) do |i|
          x = ( xg.rank==1 ? xg[i] : xg[i,j] )
          y = ( yg.rank==1 ? yg[j] : yg[i,j] )
          if ( ( fx.is_a?(NArrayMiss) && !fx.valid?[i,j] ) ||
               ( fy.is_a?(NArrayMiss) && !fy.valid?[i,j] ) )
            DCL.sgpmzu([x],[y],itype2,index,rsizem) if lmissp
            next
          end
          vx0, vy0 = DCL.stftrf(x, y) 
          xrev, yrev = DCL.stitrf(vx0, vy0)
          xdif = (xrev-x).abs
          ydif = (yrev-y).abs
          xdif = 360.0-xdif if map_proj && xdif > 359.0
          if xdif > dbk || ydif > dbk
            next   # Not plotted, because the current point is on the backside
          end
          if umodi
            cos = ( cosphi.rank==1 ? cosphi[j] : cosphi[i,j] )
          end
          um = NMatrix[ [x,x], [y,y] ]
          u[0,0],u[0,1] = DCL.stitrf(vx0+ddv, vy0)
          u[1,0],u[1,1] = DCL.stitrf(vx0, vy0+ddv)
          ap = u - um 
          (ap[true,0] >=  180.0).where.to_a.each{|i| ap[i,0] -= 360.0}
          (ap[true,0] <= -180.0).where.to_a.each{|i| ap[i,0] += 360.0}
          u[0,0],u[0,1] = DCL.stitrf(vx0-ddv, vy0)
          u[1,0],u[1,1] = DCL.stitrf(vx0, vy0-ddv)
          an = um - u
          (an[true,0] >=  180.0).where.to_a.each{|i| an[i,0] -= 360.0}
          (an[true,0] <= -180.0).where.to_a.each{|i| an[i,0] += 360.0}
          if umodi
            ap[0,0] *= cos
            ap[1,0] *= cos
            an[0,0] *= cos
            an[1,0] *= cos
          end
          f = NVector[ fx[i,j],fy[i,j] ]
          vfp = nil
          begin
            aip = ap.inverse
            vfp = aip * f
          rescue
          end
          vfn = nil
          begin
            ain = an.inverse
            vfn = ain * f
          rescue
          end
          if vfp && vfn
            vf = (vfp+vfn)/2
            err = (vfp - vfn).abs.max / vf.abs.max
            vn = vf * ( vfratio*flen[i,j] / Math.sqrt(vf[0]**2+vf[1]**2) )
            if err>=eps  
              DCL.sgpmzv([vx0],[vy0],itype2,index,rsizem) if lmissp
            elsif vn[0].nan? || vn[1].nan?
              DCL.sgpmzv([vx0],[vy0],itype2,index,rsizem)
            else
              DCL.sglazv(vx0, vy0, vx0+vn[0], vy0+vn[1], 1, index) 
            end
          end
        end
      end
      [ vfratio, flenmax ]
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
      ["inffact", 2.25, "factor to change the length of triangle on the side for infinity (relative to 'vwidth')"],
      ["landscape", false, "if true, horizonlly long (along x axes)"],
      ["portrait", true, "if true, vertically long (along y axes)"],
      ["top",  false, "place the bar at the top (effective if landscape)"],
      ["left", false, "place the bar in the left (effective if portrait)"],
      ["units", nil, "units of the axis of the color bar"],
      ["units_voff", 0.0, "offset value for units from the default position in the V coordinate (only for 'units' != nil)"],
      ["title", nil, "title of the color bar"],
      ["title_voff", 0.0, "offset value for title from the default position in the V coordinate (only for 'title' != nil)"],
      ["tickintv", 1, "0,1,2,3,.. to specify how frequently the dividing tick lines are drawn (0: no tick lines, 1: every time, 2: ever other:,...)"],
      ["labelintv", nil, "0,1,2,3,.. to specify how frequently labels are drawn (0: no labels, 1: every time, 2: ever other:,... default: internally determined)"],
      ["labels_ud", nil, "user-defined labels for replacing the default labels (Array of String)"],
      ["charfact", 0.9, "factor to change the label/units/title character size (relative to 'rsizel1')"],
      ["log", false, "set the color bar scale to logarithmic"],
      ["constwidth", false, "if true, each color is drawn with the same width"],
      ["index", nil, "index of tick lines and bar frame"],
      ["charindex", nil, "index of labels, units, and title"],
      ["chval_fmt", nil, "string to specify the DCL.chval format for labeling"]
    )

    def set_color_bar_options(options)
      @@color_bar_options.set(options)
    end

    def log10_safe(val)
      begin
        Math::log10(val)
      rescue Errno::ERANGE
        nil
      end
    end

    def log10_or_0(val)
      log10_safe(val) || 0
    end

    def level_chval_fmt(max,min,dx)
      # returns a format for DCL.chval suitable for color-bar labels
      dxabs = dx.abs
      eps = 1e-4 * dxabs
      order = log10_or_0(dxabs).floor
      if ( (dxabs+eps*0.1) % 10**order < eps )
        # 1 keta
        least_order = order
      else
        # >=2 keta --> limit to 2 keta
        least_order = order - 1
      end
      ng = log10_or_0([max.abs,min.abs,eps].max).floor - least_order + 1
      if ng <= 3
        fmt = 'b'
      else
        n = log10_or_0([max.abs,min.abs].max).floor
        nn = log10_or_0([max.abs,min.abs].min).floor
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
          ng = log10_or_0([max.abs,min.abs,eps].max).floor - least_order + 1
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
        n = log10_or_0(x.abs).floor
        fg = ((0 <= n) && (n <= 4)) ? 'f' : 'g'
      end
      eps = 1e-6
      if ( dx.abs % 10**log10_or_0(dx.abs) < eps )
        # 1 keta
        least_order = log10_or_0(dx.abs).floor
      else
        # >=2 keta --> limit to 2 keta
        least_order = log10_or_0(dx.abs).floor - 1
      end
      if fg == 'g'
        ng = log10_or_0([max.abs,min.abs,eps].max).floor - least_order + 1
        ng = [ ng, 2 ].max
        fmt = "%.#{ng}g"
      else
        nf = [ -least_order, 0].max
        fmt = "%.#{nf}f"
      end
      sprintf(fmt,x).sub(/\.0*$/,'')
    end

    def get_proj_params
      { :itr => DCL::sgqtrn,
        :vpt => DCL::sgqvpt,
        :wnd => DCL::sgqwnd,
        :sim => DCL::sgqsim,
        :cnt => DCL::umqcnt,
        :lglobe => DCL::umpget('lglobe'),
        :rsat => DCL::sgpget("rsat"),
        :txy => %w(txmin txmax tymin tymax).map{|key| DCL::sgrget(key)} }
    end

    def restore_proj_params(hash) # hash: OUTPUT OF DCLExt::get_proj_params
      DCL::grsvpt(*(hash[:vpt]))
      DCL::grswnd(*(hash[:wnd]))
      if hash[:itr] <= 4
        DCL::grstrn(hash[:itr])
      elsif hash[:itr] <= 9
        DCL::sgssim(*(hash[:sim]))
        DCL::grstrn(hash[:itr])
      elsif hash[:itr] <= 34
        DCL::sgstrn(hash[:itr])
        DCL::umpset("lglobe", hash[:lglobe])
        DCL::grstxy(*(hash[:txy]))
        DCL::umscnt(*(hash[:cnt]))
        DCL::sgpset("rsat", hash[:rsat])
        DCL::umpfit
        DCL::sgssim(*(hash[:sim]))
      end
      DCL::grstrf
    end

    def color_bar_draw_infinity(vxmin, vxmax, vymin, vymax, vwidth, portrait, inffact, sign, ipat, index)
      sign = (sign > 0) ? 1 : -1
      win = [vxmin, vxmax, vymin, vymax]
      win = win[2..3] + win[0..1] if portrait
      base = ((sign < 0) ? win[0] : win[1])
      v3 = [[base, base + vwidth * inffact * sign, base],
            [win[2], (win[2] + win[3]) / 2, win[3]]]
      v3 = [v3[1], v3[0]] if portrait
      DCL.sgtnzv(v3[0], v3[1], ipat)
      DCL.sgplzv(v3[0], v3[1], 1, index)
    end

    def color_bar_title_units(vxmin, vxmax, vymin, vymax, portrait, voff, title, units, title_voff, units_voff)
      rsizel1 = DCL::uzrget('rsizel1')
      charindex = DCL::uziget('indexl1')
      pad1 = DCL::uzrget('pad1')
      if portrait
        if voff > 0
          # title
          DCL::sgtxzr(vxmin - (0.5 + pad1) * rsizel1, (vymin + vymax) / 2.0 + title_voff, title, rsizel1, 90, 0, charindex) if title
          # units
          DCL::sgtxzr(vxmax + pad1 * rsizel1, vymax + 2.6 * rsizel1 + units_voff, units, rsizel1, 0, -1, charindex) if units
        else
          # title
          DCL::sgtxzr(vxmax + (0.5 + pad1) * rsizel1, (vymin + vymax) / 2.0 - title_voff, title, rsizel1, -90, 0, charindex) if title
          # units
          DCL::sgtxzr(vxmin - pad1 * rsizel1, vymax + 2.6 * rsizel1 + units_voff, units, rsizel1, 0, 1, charindex) if units
        end
      else
        spacer = (0.5 + pad1) * rsizel1
        tmpvy = [vymin - spacer, vymax + spacer]
        tmpvy = [tmpvy[1], tmpvy[0]] if voff <= 0
        # title
        DCL::sgtxzr((vxmin + vxmax) / 2.0 + title_voff, tmpvy[0], title, rsizel1, 0, 0, charindex) if title
        # units
        DCL::sgtxzr(vxmax + 2.6 * rsizel1 + units_voff, tmpvy[1], units, rsizel1, 0, -1, charindex) if units
      end
    end

    def color_bar_dual_log(levels, lv, patterns, portrait, opt)
      rmiss = DCL::glrget("rmiss")
      vx1, vx2, vy1, vy2 = DCL::sgqvpt
      iturn = 0
      for i in 0...levels.length
        if levels[i] != rmiss
          if levels[i] * lv[0] < 0
            iturn = i
            break
          end
        end
      end
      opt['vlength'] /= 2
      vc0 = opt['vcent'] || ( portrait && (vy1 + vy2) / 2) || (vx1 + vx2) / 2
      
      zs = (portrait ? (opt["left"] ? "yl" : 'yr') : (opt["top"] ? "xt" : 'xb'))
      zssign = (zs == "xb" || zs == "yl") ? -1 : 1
      opt["voff"] ||=
        DCL.uzrget('pad1') * DCL::uzrget("rsizec2") + DCL::uzrget("roff#{zs}") * zssign
      
      vsep2 = 0.02
      
      has_zero = (levels[iturn - 1] == 0) # zero might be located just before the sign changes
      opt['levels']   = levels[0..(iturn - (has_zero ? 2 : 1))]
      opt['patterns'] = patterns[0..(iturn - (has_zero ? 3 : 2))]
      opt['vcent'] = vc0 - opt['vlength'] / 2 - vsep2
      units = opt['units']
      opt['units'] = nil
      DCLExt.color_bar(opt)
      
      opt['levels']   = levels[iturn..-1]
      opt['patterns'] = patterns[iturn..-1]
      opt['vcent'] = vc0 + opt['vlength'] / 2 + vsep2
      opt['units'] = units
      DCLExt.color_bar(opt)
      
      # fill between the two bars
      bk = DCLExt.sg_set_params('lclip' => false)
      (has_zero ? 2 : 1).times{|i|
        if portrait
          sign = opt["left"] ? -1 : 1
          base = opt["left"] ? vx1 : vx2
          x1 = base + opt["voff"] * sign
          x2 = x1 + opt['vwidth'] * sign
          y1 = vc0 - ((has_zero && (i == 0)) ? 0 : vsep2)
          y2 = vc0 + ((has_zero && (i == 1)) ? 0 : vsep2)
        else
          x1 = vc0 - ((has_zero && (i == 0)) ? 0 : vsep2)
          x2 = vc0 + ((has_zero && (i == 1)) ? 0 : vsep2)
          sign = opt["top"] ? 1 : -1
          base = opt["top"] ? vy2 : vy1
          y1 = base + opt["voff"] * sign
          y2 = y1 + opt['vwidth'] * sign
        end
        DCL.sgtnzv([x1, x2, x2, x1], [y1, y1, y2, y2], patterns[iturn - 1 - (has_zero ? i : 0)])
        DCL.sgplzv([x1, x2, x2, x1, x1], [y1, y1, y2, y2, y1], 1, 3)
      }
      DCLExt.sg_set_params(bk)
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
      portrait  = !landscape

      
      ue_set_tone(levels, patterns) if !levels.nil?

      labels_ud = opt["labels_ud"]
      if (!labels_ud.nil? && 
          ((labels_ud.class != Array) || 
           labels_ud.empty? || 
           labels_ud.map{|lud| lud.class == String}.include?(false)))
        raise ArgumentError, "'labels_ud' must be an Array of String"
      end

      # apply optional parameters for axes and labels
      index = opt["index"] || DCL::uziget("indext2")
      index = 1 if index <= 0
      charindex = opt["charindex"] || DCL::uziget("indexl1")
      charindex = 1 if charindex <= 0
      charfact = opt["charfact"]
      charfact = 1 if charfact < 0
      rsizel1 = charfact * DCL::uzrget("rsizel1")
      axparam_bk = DCLExt.uz_set_params("indext1" => index,
                                        "indext2" => index,
                                        "indexl1" => charindex,
                                        "rsizel1" => rsizel1)

      nton = DCL::ueqntl
      raise "no tone patern was set\n" if nton == 0
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

      levels ||= lev1.push(lev2[-1])
      levels = NArray.to_na(levels) if levels.is_a?(Array)
      patterns = NArray.to_na(patterns) if patterns.is_a?(Array)

      vx1, vx2, vy1, vy2 = DCL.sgqvpt

      if opt['log']
        lv = levels[levels.ne(rmiss).where]
        if lv.length >= 4 && lv[0] * lv[-1] < 0 # log for both positive and negative
          DCLExt.color_bar_dual_log(levels, lv, patterns, portrait, opt)
          DCLExt.uz_set_params(axparam_bk)
          return
        end
      end

      if levels.length <= 1
        $stderr.print( "WARNING #{__FILE__}:#{__LINE__}: # of levels <= 1. No color bar is drawn." )
        DCLExt.uz_set_params(axparam_bk)
        return
      end

      proj_params = DCLExt.get_proj_params # BACKUP PARAMS FOR PROJECTION

      vwidth = opt["vwidth"]
      vlength = opt["vlength"]

      # compute offset from main diagram
      if portrait
        if !opt["left"] # right
          voff =  opt["voff"] ||
              DCL.uzrget('roffyr') + DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vxmin = vx2 + voff
          vxmax = vx2 + voff + vwidth
        else # left
          voff =  opt["voff"] ? -opt["voff"] : \
              DCL.uzrget('roffyl') - DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vxmax = vx1 + voff
          vxmin = vx1 + voff - vwidth
        end
        vymin =( opt["vcent"] ? opt["vcent"]-vlength/2 : vy1 )
        vymax =( opt["vcent"] ? opt["vcent"]+vlength/2 : vy1+vlength )
      else  ## landscape ##
        vxmin = (opt["vcent"] || ((vx1 + vx2) / 2)) - vlength / 2 
        vxmax = (opt["vcent"] || ((vx1 + vx2) / 2)) + vlength / 2
        if opt["top"] # top
          voff =  opt["voff"] ||
               DCL.uzrget('roffxt') + DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vymin = vy2 + voff
          vymax = vy2 + voff + vwidth
        else # bottom
          voff =  opt["voff"] ? -opt["voff"] : \
               DCL.uzrget('roffxb') - DCL.uzrget('pad1')*DCL::uzrget("rsizec2")
          vymax = vy1 + voff
          vymin = vy1 + voff - vwidth
        end
      end

      min = levels[levels.ne(rmiss).where].min
      max = levels[levels.ne(rmiss).where].max
      if (inf0 = (levels[0] == rmiss))
        dummy1,dummy2,ipat0 = DCL::ueqtlv(1)
        if levels.length==2
          DCLExt.uz_set_params(axparam_bk)
          return
        end
      end
      if (inf1 = (levels[-1] == rmiss))
        dummy1,dummy2,ipat1 = DCL::ueqtlv(nton)
        if levels.length==2
          DCLExt.uz_set_params(axparam_bk)
          return
        end
      end

      # < paint color tones >

      lclip_bk = DCLExt.sg_set_params("lclip" => false)

      inffact = opt["inffact"]
      # paint color tones for infinity (with drawing frame)
      if inf0
        DCLExt.color_bar_draw_infinity(vxmin, vxmax, vymin, vymax, vwidth, portrait, inffact, -1, ipat0, index)
      end
      if inf1
        DCLExt.color_bar_draw_infinity(vxmin, vxmax, vymin, vymax, vwidth, portrait, inffact, 1, ipat1, index)
      end
      # paint color tones for each range (with drawing long-side frame)
      if opt["constwidth"]

        levels = levels[(inf0 ? 1 : 0)..(inf1 ? -2 : -1)]
        patterns = patterns[(inf0 ? 1 : 0)..(inf1 ? -2 : -1)]
        nlev = levels.length
        npat = patterns.length

        if portrait
          vy = (NArray.sfloat(npat+1).indgen!)*(vymax-vymin)/npat + vymin
          # paint color tones for each range (with drawing long-side frame)
          for i in 0..npat-1
            DCL::sgtnzv([vxmin, vxmax, vxmax, vxmin], vy[[i, i, i + 1, i + 1]], patterns[i])
          end
          [vxmin, vxmax].each{|x| DCL::sgplzv([x] * 2, vy[[0, -1]], 1, index)}

        else ## landscape ##
          vx = (NArray.sfloat(npat+1).indgen!)*(vxmax-vxmin)/npat + vxmin
          # paint color tones for each range (with drawing long-side frame)
          for i in 0..npat-1
            DCL::sgtnzv(vx[[i, i, i + 1, i + 1]], [vymin, vymax, vymax, vymin], patterns[i])
          end
          [vymin, vymax].each{|y| DCL::sgplzv(vx[[0, -1]], [y] * 2, 1, index)}
        end

      else  ### opt["constwidth"] == false ###
        # paint color tones for each range
        nbar = 100
        bar = NArray.float(nbar,2)
        for i in 0..nbar-1
          bar[i,true] = min + (max-min).to_f/(nbar-1)*i
        end
        
        labelxbyl_bk = DCLExt.uz_set_params("labelxb" => landscape,
                                            "labelyl" => portrait)
        if portrait
          cbwindow = [0.0, 1.0, min, max]
          bar = bar.transpose(-1,0)
          DCL::uwsgxa([0,1])
          DCL::uwsgya(bar[0,true])
        else
          cbwindow = [min, max, 0.0, 1.0]
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
        DCL::grswnd(*cbwindow)
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
        labelintv = (ntn - 1) / (portrait ? 9 : 5) + 1
      end
      no_label = (labelintv <= 0)
      labelintv = 1 if no_label

      tickintv = opt["tickintv"]
      no_tick = (tickintv <= 0)
      tickintv = labelintv if no_tick

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

        DCLExt.color_bar_title_units(vxmin, vxmax, vymin, vymax, portrait, voff, 
                                     opt['title'], opt['units'], opt['title_voff'], opt['units_voff'])
        if portrait
          cent = ((voff > 0) ? -1 : 1)
          spacer = DCL::uzrget('pad1') * rsizel1
          vxlabel = (voff > 0) ? (vxmax + spacer) : (vxmin - spacer)

          ilbl_ud = 0
          for i in 0..nlev-1
            # labels
            if !no_label && (i % labelintv) == offs_label
              if labels_ud
                char = labels_ud[ilbl_ud]
                DCL::sgtxzr(vxlabel, vy[i], char, rsizel1, 0, cent, charindex)
                ilbl_ud += 1
              else
                begin
                  if(opt['chval_fmt'])
                    char = DCL::chval(opt['chval_fmt'],levels[i])
                  else
                    char = sprintf_level(levels[i],lvmx,lvmn,dlv)
                  end
                  DCL::sgtxzr(vxlabel, vy[i], char, rsizel1, 0, cent, charindex)
                rescue
                  DCL::sgtxzr(vxlabel, vy[i], levels[i].to_s, rsizel1, 0, cent, charindex)
                end
              end
            end
            # tick lines and short-side frame
            if (!no_tick && (i % tickintv) == offs_tick) || (!inf0 && i == 0) || (!inf1 && i == nlev-1)
              DCL::sgplzv([vxmin,vxmax],[vy[i],vy[i]],1,index)
            end
          end

        else  ## landscape ##
          spacer = (0.5 + DCL::uzrget('pad1')) * rsizel1
          tmpvy = [vymin - spacer, vymax + spacer]
          tmpvy = [tmpvy[1], tmpvy[0]] if voff <= 0
          vylabel = tmpvy[1]

          ilbl_ud = 0
          for i in 0..nlev-1
            # labels
            if !no_label && (i % labelintv) == offs_label
              if labels_ud
                char = labels_ud[ilbl_ud]
                DCL::sgtxzr(vx[i], vylabel, char, rsizel1, 0, 0, charindex)
                ilbl_ud += 1
              else
                begin
                  if(opt['chval_fmt'])
                    char = DCL::chval(opt['chval_fmt'],levels[i])
                  else
                    char = sprintf_level(levels[i],lvmx,lvmn,dlv)
                  end
                  DCL::sgtxzr(vx[i], vylabel, char, rsizel1, 0, 0, charindex)
                rescue
                  DCL::sgtxzr(vx[i], vylabel, levels[i].to_s, rsizel1, 0, 0, charindex)
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

        inner_bk = DCLExt.uz_set_params('inner' => 1)

        tick1 = Array.new
        tick2 = Array.new
        for i in 0..levels.length-1
#          if i>=idumin && i<=idumax && levels[i]!=rmiss
          if levels[i]!=rmiss
            tick1.push(levels[i]) if (i % tickintv) == offs_tick
            tick2.push(levels[i]) if (i % labelintv) == offs_label
          end
        end

        fmt = opt['chval_fmt'] || (opt["log"] ? "b" : DCLExt.level_chval_fmt(lvmx, lvmn, dlv))
        rsizet12_bk = DCLExt.uz_set_params('rsizet1' => no_tick ? 0.0 : vwidth, 'rsizet2' => 0.0)

        if portrait

          if no_label
            before = DCLExt.uz_set_params(Hash[*(%w(xt xb yl yr).map{|zs| ["label#{zs}", false]}.flatten)])
          else
            before = DCLExt.uz_set_params('labelyl' => (voff <= 0), 
                                          'labelyr' => (voff > 0), 
                                          'icentyr' => ((voff > 0) ? -1.0 : 1.0))
          end

          # draw frame, tick lines, and labels
          cfmt_bk = DCL::uyqfmt
          DCL::uysfmt(fmt)

          if labels_ud
            if labels_ud.size != tick2.size
              raise ArgumentError, "'labels_ud' must be an Array of length==#{tick2.size} in this case"
            end
            nc = labels_ud.collect{|c| c.size}.max
            ["l", "r"].each{|cs| DCL::uyaxlb(cs, tick1, tick2, labels_ud, nc)}
          else
            ["l", "r"].each{|cs| DCL::uyaxnm(cs, tick1, tick2)}
          end
          DCL::uxaxdv("b",1,index) if !inf0
          DCL::uxaxdv("t",1,index) if !inf1

          DCL::uysfmt(cfmt_bk)

        else  ## landscape ##

          if no_label
            before = DCLExt.uz_set_params(Hash[*(%w(xt xb yl yr).map{|zs| ["label#{zs}", false]}.flatten)])
          else
            before = DCLExt.uz_set_params('labelxt' => (voff > 0), 'labelxb' => (voff <= 0))
          end

          # draw frame, tick lines, and labels
          cfmt_bk = DCL::uxqfmt
          DCL::uxsfmt(fmt)

          if labels_ud
            if labels_ud.size != tick2.size
              raise ArgumentError, "'labels_ud' must be an Array of length==#{tick2.size} in this case"
            end
            nc = labels_ud.collect{|c| c.size}.max
            ["t", "b"].each{|cs| DCL::uxaxlb(cs, tick1, tick2, labels_ud, nc)}
          else
            ["t", "b"].each{|cs| DCL::uxaxnm(cs, tick1, tick2)}
          end
          DCL::uyaxdv("l",1,index) if !inf0
          DCL::uyaxdv("r",1,index) if !inf1

          DCL::uxsfmt(cfmt_bk)
        end
        DCLExt.color_bar_title_units(vxmin, vxmax, vymin, vymax, portrait, voff, 
                                     opt['title'], opt['units'], opt['title_voff'], opt['units_voff'])

        # RESTORE PARAMS
        DCLExt.restore_proj_params(proj_params)
        DCLExt.uz_set_params(before) ### labelzs
        DCLExt.uz_set_params(rsizet12_bk)
        DCLExt.uz_set_params(labelxbyl_bk) if labelxbyl_bk
        DCLExt.uz_set_params(inner_bk)
      end

      DCLExt.uz_set_params(axparam_bk)
      DCLExt.sg_set_params(lclip_bk)
      nil
    end

    # Annotates line/mark type and index (and size if mark).
    # By default it is shown in the right margin of the viewport.
    #
    # * str is a String to show
    # * line: true->line ; false->mark
    # * vx: vx of the left-hand point of legend line (or mark position).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    #     * Float && < 0 : move it relatively to the left from the default
    # * dx: length of the legend line (not used if mark).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    # * vy: vy of the legend (not used if !first -- see below).
    #     * nil : internally determined
    #     * Float && > 0 : set explicitly
    #     * Float && < 0 : move it relatively lower from the default
    # * first : if false, vy is moved lower relatively from the previous vy.
    # * mark_size : size of the mark. if nil, size is used.
    def legend(str, type, index, line=false, size=nil,
               vx=nil, dx=nil, vy=nil, first=true, mark_size=nil)

      size ||= DCL::uzrget("rsizel1") * 0.95
      mark_size ||= size

      vpx1,vpx2,vpy1,vpy2 = DCL.sgqvpt
      if first || (!@vy)
        vy ||= vpy2 - 0.04
        vy += vpy2 - 0.04 if vy < 0
      else
        vy ||= @vy - 1.5 * size
      end
      @vy = vy

      vx ||= vpx2 + 0.015
      vx = (vpx2 + 0.015) + vx if vx < 0

      if line
        dx ||= 0.06
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
    #     (usig +-[lev0.abs,lev1.abs])
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

end

if $0 == __FILE__
  include NumRu

  require "numru/derivative"
  include Misc::EMath
  nx = 33
  ny = 17
  x = NArray.sfloat(nx).indgen! * (2*PI/(nx-1))
  #y = ( NArray.sfloat(ny).indgen! - (ny-1)/2.0 ) *(PI/ny)
  y = ( NArray.sfloat(ny).indgen! - (ny-1)/2.0 ) *(PI/(ny-1))
  #p x,y
  xdeg = x*(180/PI)
  ydeg = y*(180/PI)
  #xdegc = xdeg[[0..-1,0]]
  #xdegc[-1] += 360
  xx = x.newdim(1)
  yy = y.newdim(0)
  z = (cos(4*yy)-1)*sin(2*xx) - 2*cos(2*yy)
  u = - Derivative.cderiv(z,y,1,Derivative::CYCLIC_EXT)
  v =   Derivative.cderiv(z,x,0,Derivative::CYCLIC_EXT) / cos(yy)
  u = NArrayMiss.to_nam(u)
  #DCL.ugpset('lmissp',true)
  u.invalidation(2..6,-5..-2)
  v[7..10,-5] = 999.0
  
  DCL.gropn(1)
  DCL.glpset('lmiss',true)

  DCL.sgpset('lclip',true)

  for itr in [10,12]
    DCL.grfrm
    DCL.grstrn(itr)
    DCL.grsvpt(0.1,0.9,0.25,0.75)
    DCL.umscnt(180, 0, 0)
    DCL.grswnd(xdeg[0],xdeg[-1],ydeg[0],ydeg[-1])
    DCL.grstxy(-180, 180, -90, 90 )
    DCL.umpset('lglobe', true)
    DCL.umpfit
    DCL.grstrf
    DCL.udcntz(z)
    vfratio, flenmax = DCLExt.flow_vect_anyproj(u, v, xdeg, ydeg)
    DCLExt.unit_vect_single(vfratio, flenmax)
    DCL.umplim
  end

  itr = 30
  DCL.grfrm
  DCL.grstrn(itr)
  DCL.grsvpt(0.1,0.9,0.1,0.9)
  DCL.umscnt(180, 90, 0)
  DCL.grswnd(xdeg[0],xdeg[-1],ydeg[0],ydeg[-1])
  DCL.grssim(0.3,0,0)
  DCL.grstxy(-180, 180, 10, 90 )
  DCL.umpset('lglobe', true)
  DCL.umpfit
  DCL.grstrf
  DCL.udcntz(z)
  vfratio, flenmax = 
    DCLExt.flow_vect_anyproj(u[true,ny/2+1..-1], v[true,ny/2+1..-1],
                                xdeg, ydeg[ny/2+1..-1])
  DCLExt.unit_vect_single(vfratio, flenmax)
  DCL.umplim

  itr = 30
  DCL.grfrm
  DCL.grstrn(itr)
  DCL.grsvpt(0.1,0.9,0.1,0.9)
  DCL.umscnt(180, 30, 0)
  DCL.grswnd(xdeg[0],xdeg[-1],ydeg[0],ydeg[-1])
  DCL.grssim(0.3,0,0)
  DCL.grstxy(-180, 180, 0, 90 )
  DCL.umpset('lglobe', true)
  DCL.umpfit
  DCL.grstrf
  #DCL.udcntz(z[true,ny/2+1..-1])
  DCL.uepset("ltone",true)
  DCL.udcntz(z[true,ny/2+1..-1])
  vfratio, flenmax = 
    DCLExt.flow_vect_anyproj(u, v,
                                xdeg, ydeg,
                                1.0,1,1,true,nil,0.3)
    #DCLExt.flow_vect_anyproj(u[true,ny/2..-1], v[true,ny/2..-1],
    #                            xdeg, ydeg[ny/2..-1])
  DCLExt.unit_vect_single(vfratio, flenmax)
  DCL.umplim

  ## for datetime_ax
  date_from = DateTime.parse('2005-06-30 17:00')
  date_to = DateTime.parse('2005-07-01 5:00')
  date_from2 = DateTime.parse('2005-06-29 17:00')
  date_to2 = DateTime.parse('2005-07-02 5:00')

  any_offst = 10

  DCL.grfrm
  DCL.grswnd(0.0, date_to-date_from, any_offst, date_to2-date_from2+any_offst)
  DCL.grsvpt(0.2, 0.8, 0.2, 0.8)
  DCL.grstrn(1)
  DCL.grstrf
  DCLExt.datetime_ax(date_from,  date_to,                 'year'=>true)
  DCLExt.datetime_ax(date_from,  date_to, 'cside'=>'t',   'year'=>true)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 'cside'=>'r')
  DCL.uxsttl('b','TIME AND DATE',0.0)
  DCL.uysttl('l','TIME AND DATE',0.0)

  DCL.grfrm
  DCL.grswnd(0.0, date_to-date_from, 0, date_to2-date_from2)
  DCL.grsvpt(0.2, 0.8, 0.2, 0.8)
  DCL.grstrn(1)
  DCL.grstrf
  DCL.uzpset('inner',-1)
  DCLExt.datetime_ax(date_from,  date_to,               'dtick2'=>2)
  DCLExt.datetime_ax(date_from,  date_to, 'cside'=>'t', 'dtick2'=>2)
  DCL.uzpset('inner',1)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 
                     'dtick1'=>2, 'dtick2'=>24)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 'cside'=>'r',
                     'dtick1'=>2, 'dtick2'=>24)
  DCL.uxsttl('b','TIME AND DATE',0.0)
  DCL.uysttl('l','TIME AND DATE',0.0)

  ## for date_ax
  date_from = DateTime.parse('1995-06-30 17:00')
  date_to = DateTime.parse('2000-02-01 5:00')
  any_offst = 10

  3.times do
    DCL.grfrm
    DCL.grswnd(0.0, date_to-date_from, any_offst, date_to-date_from+any_offst)
    DCL.grsvpt(0.2, 0.8, 0.2, 0.8)
    DCL.grstrn(1)
    DCL.grstrf
    #DCL.uzpset("irotcyl",0)
    #DCL.uzpset("irotcxb",1)
    DCLExt.date_ax(date_from,  date_to)
    DCLExt.date_ax(date_from,  date_to, "yax"=>true)
    date_to = date_to >> 15*12
  end

  DCL.grcls

end
