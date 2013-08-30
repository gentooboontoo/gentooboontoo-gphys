require 'numru/ggraph'
require 'numru/gphys/ep_flux'

############################################################

=begin
=module NumRu::GGraph in vector_on_merdional_section.rb

This file defines additional method of NumRu::GGraph. This method is for 
drawing vector on merdional sections.

==Index
* ((<module NumRu::GGraph>))
  * ((<vector_on_merdional_section>))
    Draw vector by selecting the first 2 dimensions 
    (with GPhys#first2D) if (({gphys})) is more than 3D.

==Module Functions

---vector_on_merdional_section(fx, fy, newframe=true, options=nil)
    Draw vector by selecting the first 2 dimensions 
    (with GPhys#first2D) if (({gphys})) is more than 3D.

    ARGUMENTS
    * fx (GPhys) : a GPhys whose data is plotted x-componet.
    * fy (GPhys) : a GPhys whose data is plotted y-componet.
    * newframe (true/false) : if true, calls ((<fig>)), ((<axes>)),
      ((<title>)), and ((<annotate>)) internally; if false, only
      the poly-line is drawn (overlaid to the exiting figure).
    * options (Hash) : options to change the default behavior if specified.
      It is a Hash with option names (String) as keys and their values.
      Options are interpreted by a NumRu::Misc::KeywordOptAutoHelp,
      so you can shorten the keys (by omitting tails) as long as it is 
      unambiguous.
       option name     default value # description:
       "title"         nil           # Title of the figure(if nil, internally 
                                     # determined)
       "annotate"      true          # if false, do not put texts on the right
                                     # margin even when newframe==true
       "transpose"     false         # if true, exchange x and y axes
       "flow_vect"     true          # If true, use DCLExt::flow_vect to draw
                                     # vectors; otherwise, DCL::ugvect is used
       "xintv"         1             # (Effective only if flow_vect) interval
                                     # sampling in x of data 
       "yintv"         1             # (Effective only if flow_vect) interval
                                     # of data sampling in y 
       "factor"        1.0           # (Effective only if flow_vect) scaling 
                                     # factor to strech/reduce the arrow 
                                     # lengths.
       "use_before_scale"            #
                       false         #(Effective only unless flow_vect) If true, 
                                     # use scale factor before vector.
       "unit_vect"     false         # Show the unit vector
       "max_unit_vect" false         # (Effective only if flow_vect && 
                                     # unit_vect) If true, use the maximum 
                                     # arrows to scale the unit vector; 
                                     # otherwise, normalize in V coordinate.

    RETURN VALUE
    * nil

=end

############################################################

module NumRu

  module GGraph

    module_function

    def vector_on_merdional_section(fx, fy, newframe=true, options=nil)  
      if ! defined?(@@vector_on_merdional_section_options)
        @@vector_on_merdional_section_options = Misc::KeywordOptAutoHelp.new(
          ['newfig', true, 'if false, do not cleared before figure setting.'],
          ['title', nil, 'Title of the figure(if nil, internally determined)'],
          ['annotate', true, 'if false, do not put texts on the right margin even when newframe==true'],
          ['transpose', false, 'if true, exchange x and y axes'],
          ['flow_vect', true, 'If true, use DCLExt::flow_vect to draw vectors; otherwise, DCL::ugvect is used.'],
          ['xintv', 1, '(Effective only if flow_vect) interval of data sampling in x'],
          ['yintv', 1, '(Effective only if flow_vect) interval of data sampling in y'],
          ['factor', 1.0, '(Effective only if flow_vect) scaling factor to strech/reduce the arrow lengths'],
          ['unit_vect', false, 'Show the unit vector'],
          ['use_before_scale', false, '(Effective only unless flow_vect) If true, use scale factor before vector.'],
          ['max_unit_vect', false, '(Effective only if flow_vect && unit_vect) 
            If true, use the maximum arrows to scale the unit vector; otherwise, normalize in V coordinate.']
        )
      end
      opts = @@vector_on_merdional_section_options.interpret(options)
      fx = fx.first2D.copy
      fy = fy.first2D.copy
      sh = fx.shape
      if sh != fy.shape
        raise ArgumentError, "shapes of fx and fy do not agree with each other"
      end
      fx = fx.transpose(1,0) if opts['transpose']
      fy = fy.transpose(1,0) if opts['transpose']
      if ((xi=opts['xintv']) >= 2)
        idx = NArray.int(sh[0]/xi).indgen!*xi     # [0,xi,2*xi,..]
        fx = fx[idx, true]
        fy = fy[idx, true]
      end
      if ((yi=opts['xintv']) >= 2)
        idx = NArray.int(sh[1]/yi).indgen!*yi     # [0,yi,2*yi,..]
        fx = fx[true, idx]
        fy = fy[true, idx]
      end
      xax = fx.coord(0)
      yax = fy.coord(1)
      aphi_ax, z_ax, was_proportional_to_p = \
            GPhys::EP_Flux::preparate_for_vector_on_merdional_section(xax, yax)
      if was_proportional_to_p
	itr = 2 
      else
	itr = 1
      end
      if newframe
	nextfig = @@next_fig.dup  if ( @@next_fig != nil ) # backup next_fig
        fig(xax, yax, {'itr'=>itr}) 
        axes(xax, yax)
        if opts['title']
          ttl = opts['title']
        else
          fxnm = fx.data.get_att('long_name') || fx.name
          fynm = fy.data.get_att('long_name') || fy.name
          ttl =   '('+fxnm+','+fynm+')'
        end
        title( ttl )
        annotate(fx.lost_axes) if opts['annotate']
	@@next_fig = nextfig      if ( @@next_fig != nil )
      end
      fig(aphi_ax, z_ax, {'new_frame'=>false, 'itr'=>1, 'yreverse'=>false}) \
                                                          if (opts['newfig'])
      DCL.uwsgxa(aphi_ax.val) 
      DCL.uwsgya(z_ax.val)
      if opts['flow_vect']
	if opts['use_before_scale']
	  vxfxratio = @@uninfo[0]; vxfyratio = @@uninfo[1]
	  before=DCLExt.ug_set_params( {'LNRMAL'=>false, 'LMSG'=>false,
					 'XFACT1'=>1.0, 'YFACT1'=>1.0} )
	  DCL.ugvect(vxfxratio*fx.val, vxfyratio*fy.val)
	  DCLExt.ug_set_params(before) 
	  if opts['unit_vect']
	    if opts['max_unit_vect']
	      DCLExt.unit_vect(*@@uninfo)
	    else
	      DCLExt.unit_vect(*@@uninfo[0..1])
	    end
	  end
	else
	  @@uninfo = DCLExt.flow_vect(fx.val, fy.val, opts['factor'] )
	  if opts['unit_vect']
	    if opts['max_unit_vect']
	      DCLExt.unit_vect(*@@uninfo)
	    else
	      DCLExt.unit_vect(*@@uninfo[0..1])
	    end
	  end
	end
      else
	if opts['use_before_scale']
	  vxfxratio = @@uninfo[0]; vxfyratio = @@uninfo[1]
	  before1=DCLExt.ug_set_params({'lunit'=>true}) if opts['unit_vect']
	  before2=DCLExt.ug_set_params( {'LNRMAL'=>false, 'LMSG'=>false,
					 'XFACT1'=>1.0, 'YFACT1'=>1.0} )
	  DCL.ugvect(vxfxratio*fx.val, vxfyratio*fy.val)
	  DCLExt.ug_set_params(before1) if opts['unit_vect']
	  DCLExt.ug_set_params(before2) 
	else
	  before=DCLExt.ug_set_params({'lunit'=>true}) if opts['unit_vect']
	  DCL.ugvect(fx.val, fy.val)
	  DCLExt.ug_set_params(before) if opts['unit_vect']
	end
	nil
      end
    end
  end
end
