#include "vector.hpp"

namespace VectorCategories{

        template<typename T>
        std::vector<T> concatenateVectors(const std::vector<std::vector<T>>& vectors) {
                std::vector<T> result;
                for (const auto& vec : vectors) {
                        result.insert(result.end(), vec.begin(), vec.end());
                }
                return result;
        }

        std::vector<std::string> rvv_int_add_sub = { 
                                        "vadd.vv", "vadd.vx", "vadd.vi", 
                                        "vsub.vv", "vsub.vx", 
                                        "vrsub.vx","vrsub.vi"
                                },
                                rvv_int_widening_add_sub =  { 
                                        "vwaddu.vv", "vwaddu.vx",  
                                        "vwsubu.vv", "vwsubu.vx",  
                                        "vwadd.vv",  "vwadd.vx",  
                                        "vwsub.vv",  "vwsub.vx",
					                    "vwaddu.wv", "vwaddu.wx",
					                    "vwsubu.wv", "vwsubu.wx",
					                    "vwadd.wv", "vwadd.wx",
                                        "vwsub.wv", "vwsub.wx"  
                                }, 
                                rvv_int_sign_extension = { 
                                        "vzext.vf2", "vsext.vf2",
                                        "vzext.vf4", "vsext.vf4",
                                        "vzext.vf8", "vsext.vf8"
                                },
                                rvv_int_addwc_subwb = { 
                                        "vadc.vvm","vadc.vxm","vadc.vim",
                                        "vmadc.vvm","vmadc.vxm","vmadc.vim",
                                        "vmadc.vv","vmadc.vx","vmadc.vi",
                                        "vsbc.vvm","vsbc.vxm",
                                        "vmsbc.vvm","vmsbc.vxm",
                                        "vmsbc.vv","vmsbc.vx"
                                        },
                                rvv_int_bitwise_logical = {
                                        "vand.vv","vand.vx","vand.vi",       
                                        "vor.vv", "vor.vx", "vor.vi",        
                                        "vxor.vv","vxor.vx","vxor.vi"      
                                        },
                                rvv_int_single_width_shift = {
                                        "vsll.vv", "vsll.vx", "vsll.vi", 
                                        "vsrl.vv", "vsrl.vx", "vsrl.vi", 
                                        "vsra.vv", "vsra.vx", "vsra.vi" 
                                        },
                                rvv_int_narrowing_right_shift = {
                                        "vnsrl.wv", "vnsrl.wx", "vnsrl.wi", 
                                        "vnsra.wv", "vnsra.wx", "vnsra.wi" 
                                        },
                                rvv_int_narrowing_clip = {
                                        "vnclipu.wv", "vnclipu.wx", "vnclipu.wi",
                                        "vnclip.wv", "vnclip.wx", "vnclip.wi"
                                        },
                                rvv_int_compare = {
                                        "vmseq.vv", "vmsne.vv", "vmsle.vv", "vmslt.vv",
                                        "vmseq.vx", "vmsltu.vv", "vmsleu.vv", "vmsne.vx", 
                                        "vmslt.vx", "vmsle.vx", "vmsgt.vx", "vmsleu.vx",
                                        "vmsltu.vx","vmsgtu.vx", "vmseq.vi", "vmsne.vi",
                                        "vmsgt.vi", "vmsle.vi", "vmsleu.vi", "vmsgtu.vi" 
                                        },
                                rvv_int_min_max = {
                                        "vminu.vv", "vminu.vx", "vmaxu.vv", "vmaxu.vx",
                                        "vmin.vv", "vmin.vx", "vmax.vv", "vmax.vx"
                                        },
                                rvv_int_single_width_multiply = {
                                        "vmul.vv", "vmul.vx", 
                                        "vmulh.vv", "vmulh.vx", 
                                        "vmulhu.vv", "vmulhu.vx", 
                                        "vmulhsu.vv", "vmulhsu.vx" 
                                        },
                                rvv_int_divide = {
                                        "vdivu.vv", "vdivu.vx", 
                                        "vdiv.vv", "vdiv.vx",
                                        "vremu.vv", "vremu.vx", 
                                        "vrem.vv", "vrem.vx"
                                        },
                                rvv_int_widening_multiply = {
                                        "vwmul.vv", "vwmul.vx",
                                        "vwmulu.vv","vwmulu.vx",
                                        "vwmulsu.vv","vwmulsu.vx" 
                                        },
                                rvv_int_widening_mul_add = {
                                        "vwmaccu.vv", "vwmaccu.vx",
                                        "vwmacc.vv", "vwmacc.vx",
                                        "vwmaccsu.vv", "vwmaccsu.vx",
                                        "vwmaccus.vx"
                                        },
                                rvv_int_single_width_mul_add = {
                                        "vmacc.vv", "vmacc.vx",   
                                        "vnmsac.vv","vnmsac.vx",   
                                        "vmadd.vv", "vmadd.vx",   
                                        "vnmsub.vv","vnmsub.vx"   
                                        },
                                rvv_int_merge = {
                                        "vmerge.vvm", 
                                        "vmerge.vxm", 
                                        "vmerge.vim" 
                                        },
                                rvv_int_move = {
                                        "vmv.v.v",
                                        "vmv.v.x",
                                        "vmv.v.i"
                                        },
                                rvv_mask_logical = {
                                        "vmandn.mm",
                                        "vmand.mm",
                                        "vmor.mm",
                                        "vmxor.mm",
                                        "vmorn.mm",
                                        "vmnand.mm",
                                        "vmnor.mm",
                                        "vmxnor.mm" 
                                        },
                                rvv_mask_vcpop = {
                                        "vcpop.m"
                                        },
                                rvv_mask_vfirst = {
                                        "vfirst.m"
                                        },
                                rvv_mask_vmsbf = {
                                        "vmsbf.m"
                                        },
                                rvv_mask_vmsif = {
                                        "vmsif.m"
                                        },
                                rvv_mask_vmsof = {
                                        "vmsof.m"
                                        },
                                rvv_mask_viota = {
                                        "viota.m"
                                        },
                                rvv_mask_vid = {
                                        "vid.v"
                                        },
                                rvv_int_scalar_move = {
                                        "vmv.x.s",
                                        "vmv.s.x"
                                        },
                                rvv_fp_scalar_move = {
                                        "vfmv.f.s",
                                        "vfmv.s.f"
                                        },
                                rvv_int_slideup = {
                                        "vslideup.vx",
                                        "vslideup.vi",
                                        "vslide1up.vx"
                                        },
                                rvv_int_slidedown = {
                                        "vslidedown.vx",
                                        "vslidedown.vi",
                                        "vslide1down.vx"
                                        },
                                rvv_fp_slideup = {
                                        "vfslide1up.vf"
                                        },
                                rvv_fp_slidedown = {
                                        "vfslide1down.vf"
                                        },
                                rvv_reg_gather = {
                                        "vrgather.vv",
                                        "vrgatherei16.vv",
                                        "vrgather.vi",
                                        "vrgather.vx"
                                        },
                                rvv_reg_compress = {
                                        "vcompress.vm"
                                        },
                                rvv_whole_reg_move = {
                                        "vmv1r.v",
                                        "vmv2r.v",
                                        "vmv4r.v",
                                        "vmv8r.v"
                                        },
                                rvv_int_single_width_red = {
                                        "vredsum.vs",
                                        "vredmaxu.vs",
                                        "vredmax.vs",
                                        "vredminu.vs",
                                        "vredmin.vs",
                                        "vredand.vs",
                                        "vredor.vs",
                                        "vredxor.vs"
                                        },
                                rvv_int_widening_red = {
                                        "vwredsumu.vs",
                                        "vwredsum.vs"
                                        },
                                rvv_fp_single_width_red = {
                                        "vfredosum.vs",
                                        "vfredusum.vs",
                                        "vfredmax.vs",
                                        "vfredmin.vs"
                                        },
                                rvv_fp_widening_add_sub = {
                                        "vfwadd.vv",
                                        "vfwadd.vf",
                                        "vfwsub.vv",
                                        "vfwsub.vf",
                                        "vfwadd.wv",
                                        "vfwadd.wf",
                                        "vfwsub.wv",
                                        "vfwsub.wf"
                                        },
                                rvv_fp_widening_multiply = {
                                        "vfwmul.vv", "vfwmul.vf"
                                        },
                                rvv_fp_widening_mul_add = {
                                        "vfwmacc.vv", "vfwmacc.vf",
                                        "vfwnmacc.vv", "vfwnmacc.vf",
                                        "vfwmsac.vv", "vfwmsac.vf",
                                        "vfwnmsac.vv", "vfwnmsac.vf"
                                        },
                                rvv_fp_widening_convert = {
                                        "vfwcvt.xu.f.v", "vfwcvt.x.f.v",
                                        "vfwcvt.rtz.xu.f.v", "vfwcvt.rtz.x.f.v",
                                        "vfwcvt.f.xu.v", "vfwcvt.f.x.v",
                                        "vfwcvt.f.f.v"
                                        },
                                rvv_fp_widening_red = {
                                        "vfwredosum.vs",
                                        "vfwredusum.vs"
                                        },
                                rvv_fp_narrowing_convert = {
                                        "vfncvt.xu.f.w", "vfncvt.x.f.w",
                                        "vfncvt.rtz.xu.f.w", "vfncvt.rtz.x.f.w",
                                        "vfncvt.f.xu.w", "vfncvt.f.x.w",
                                        "vfncvt.f.f.w", "vfncvt.rod.f.f.w"
                                        },
                                rvv_unit_stride_load = {
                                        "vle8.v", 
                                        "vle16.v", 
                                        "vle32.v" ,
                                        "vle64.v" 
                                        },
                                rvv_unit_stride_store = {
                                        "vse8.v", 
                                        "vse16.v", 
                                        "vse32.v" ,
                                        "vse64.v" 
                                        },
                                rvv_unit_stride_masked_load_store = {
                                        "vlm.v",
                                        "vsm.v" 
                                        },
                                rvv_indexed_ordered_load = {
                                        "vloxei8.v",      
                                        "vloxei16.v",       
                                        "vloxei32.v",       
                                        "vloxei64.v"
                                        },
                                rvv_indexed_ordered_store = {
                                        "vsoxei8.v",      
                                        "vsoxei16.v",       
                                        "vsoxei32.v",       
                                        "vsoxei64.v"       
                                        },
                                rvv_strided_load = {
                                        "vlse8.v",   
                                        "vlse16.v",   
                                        "vlse32.v",   
                                        "vlse64.v"
                                        },
                                rvv_strided_store = {
                                        "vsse8.v",  
                                        "vsse16.v",   
                                        "vsse32.v",   
                                        "vsse64.v"   
                                        },
                                rvv_indexed_unordered_load = {
                                        "vluxei8.v" ,
                                        "vluxei16.v",
                                        "vluxei32.v",
                                        "vluxei64.v",
                                        },
                                rvv_indexed_unordered_store = {
                                        "vsuxei8.v" ,
                                        "vsuxei16.v",
                                        "vsuxei32.v",
                                        "vsuxei64.v"
                                        },
                                rvv_segmented_load = {
                                        "vlsege8.v",
                                        "vlsege16.v",
                                        "vlsege32.v",
                                        "vlsege64.v"
                                        },
                                rvv_segmented_fault_first_load = {
                                        "vlsege8ff.v",
                                        "vlsege16ff.v",
                                        "vlsege32ff.v",
                                        "vlsege64ff.v"
                                        },
                                rvv_segmented_store = {
                                        "vssege8.v",
                                        "vssege16.v",
                                        "vssege32.v",
                                        "vssege64.v"
                                        },
                                rvv_ordered_indexed_segmented_load = {
                                        "vloxsegei8.v",
                                        "vloxsegei16.v",
                                        "vloxsegei32.v",
                                        "vloxsegei64.v"
                                        },
                                rvv_unordered_indexed_segmented_load = {
                                        "vluxsegei8.v",
                                        "vluxsegei16.v",
                                        "vluxsegei32.v",
                                        "vluxsegei64.v"
                                        },
                                rvv_ordered_indexed_segmented_store = {
                                        "vsoxsegei8.v",
                                        "vsoxsegei16.v",
                                        "vsoxsegei32.v",
                                        "vsoxsegei64.v",
                                        },
                                rvv_unordered_indexed_segmented_store = {
                                        "vsuxsegei8.v",
                                        "vsuxsegei16.v",
                                        "vsuxsegei32.v",
                                        "vsuxsegei64.v",
                                        },
                                rvv_strided_segmented_load = {
                                        "vlssege8.v",
                                        "vlssege16.v",
                                        "vlssege32.v",
                                        "vlssege64.v"
                                },
                                rvv_strided_segmented_store = {
                                        "vsssege8.v",
                                        "vsssege16.v",
                                        "vsssege32.v",
                                        "vsssege64.v",
                                },
                                rvv_whole_reg_load = {
                                        "vlre16.v",
                                        "vlre32.v",
                                        "vlre64.v",
                                        "vlre8.v",
                                        "vl2re16.v",
                                        "vl2re32.v",
                                        "vl2re64.v",
                                        "vl2re8.v",
                                        "vl4re16.v",
                                        "vl4re32.v",
                                        "vl4re64.v",
                                        "vl4re8.v",
                                        "vl8re16.v",
                                        "vl8re32.v",
                                        "vl8re64.v",
                                        "vl8re8.v"
                                },
                                rvv_whole_reg_store = {
                                        "vs1r.v",
                                        "vs2r.v",
                                        "vs4r.v",
                                        "vs8r.v",
                                        },
                                rvv_load_fault_only_first = {
                                        "vle8ff.v", 
                                        "vle16ff.v", 
                                        "vle32ff.v" ,
                                        "vle64ff.v" 
                                        },
                                rvv_int_vi_variants = {
                                        "vadd.vi",
                                        "vrsub.vi",       
                                        "vand.vi",       
                                        "vor.vi",       
                                        "vxor.vi",
                                        "vadc.vim",     
                                        "vmadc.vim",     
                                        "vmadc.vi",     
                                        "vmerge.vim",     
                                        "vmv.v.i",     
                                        "vmseq.vi",     
                                        "vmsne.vi",     
                                        "vmsleu.vi",     
                                        "vmsle.vi",     
                                        "vmsgtu.vi",     
                                        "vmsgt.vi",     
                                        "vsaddu.vi", 
                                        "vsadd.vi", 
                                        "vsll.vi", 
                                        "vsrl.vi", 
                                        "vsra.vi", 
                                        "vssrl.vi", 
                                        "vssra.vi", 
                                        "vnsrl.wi", 
                                        "vnsra.wi", 
                                        "vnclipu.wi", 
                                        "vnclip.wi" 
                                },
                                rvv_int_vx_variants = {
                                        "vadd.vx",       
                                        "vsub.vx",       
                                        "vrsub.vx",       
                                        "vminu.vx",       
                                        "vmin.vx",       
                                        "vmaxu.vx",       
                                        "vmax.vx",       
                                        "vand.vx",       
                                        "vor.vx",       
                                        "vxor.vx",
                                        "vadc.vxm",       
                                        "vmadc.vxm",      
                                        "vmadc.vx",       
                                        "vsbc.vxm",       
                                        "vmsbc.vxm",      
                                        "vmsbc.vx",       
                                        "vmerge.vxm",     
                                        "vmv.v.x",        
                                        "vmseq.vx",       
                                        "vmsne.vx",       
                                        "vmsltu.vx",      
                                        "vmslt.vx",       
                                        "vmsleu.vx",      
                                        "vmsle.vx",       
                                        "vmsgtu.vx",      
                                        "vmsgt.vx",
                                        "vsaddu.vx",
                                        "vsadd.vx",
                                        "vssubu.vx",
                                        "vssub.vx",
                                        "vaaddu.vx",
                                        "vaadd.vx",
                                        "vasubu.vx",
                                        "vasub.vx",
                                        "vsll.vx",
                                        "vsmul.vx",
                                        "vsrl.vx",
                                        "vsra.vx",
                                        "vssrl.vx",
                                        "vssra.vx",
                                        "vnsrl.wx",
                                        "vnsra.wx",
                                        "vnclipu.wx",
                                        "vnclip.wx",
                                        "vdivu.vx",     
                                        "vdiv.vx",     
                                        "vremu.vx",     
                                        "vrem.vx",     
                                        "vmulhu.vx",     
                                        "vmul.vx",     
                                        "vmulhsu.vx",     
                                        "vmulh.vx",     
                                        "vmadd.vx",     
                                        "vnmsub.vx",    
                                        "vmacc.vx",     
                                        "vnmsac.vx",
                                        "vwaddu.vx",    
                                        "vwadd.vx",    
                                        "vwsubu.vx",    
                                        "vwsub.vx",    
                                        "vwaddu.wx",    
                                        "vwadd.wx",    
                                        "vwsubu.wx",    
                                        "vwsub.wx",    
                                        "vwmulu.vx",    
                                        "vwmulsu.vx",    
                                        "vwmul.vx",    
                                        "vwmaccu.vx",    
                                        "vwmacc.vx",    
                                        "vwmaccus.vx",    
                                        "vwmaccsu.vx",   
                                },
                                rvv_fp_vf_variants = {
                                        "vfadd.vf",
                                        "vfsub.vf",
                                        "vfrsub.vf",
                                        "vfwadd.vf",
                                        "vfwsub.vf",
                                        "vfwadd.wf",
                                        "vfwsub.wf",
                                        "vfmul.vf",
                                        "vfdiv.vf",
                                        "vfrdiv.vf",
                                        "vfwmul.vf",
                                        "vfmacc.vf",
                                        "vfnmacc.vf",
                                        "vfmsac.vf",
                                        "vfnmsac.vf",
                                        "vfmadd.vf",
                                        "vfnmadd.vf",
                                        "vfmsub.vf",
                                        "vfnmsub.vf",
                                        "vfwmacc.vf",
                                        "vfwnmacc.vf",
                                        "vfwmsac.vf",
                                        "vfwnmsac.vf",
                                        "vfmin.vf",
                                        "vfmax.vf",
                                        "vfsgnj.vf",
                                        "vfsgnjn.vf",
                                        "vfsgnjx.vf",
                                        "vmfeq.vf",
                                        "vmfne.vf",
                                        "vmflt.vf",
                                        "vmfle.vf",
                                        "vmfgt.vf",
                                        "vmfge.vf",
                                        "vfmerge.vfm",
                                        "vfmv.v.f",
                                },
                                rvv_fp_vv_variants = {
                                        "vfadd.vv",
                                        "vfsub.vv",
                                        "vfwadd.vv",
                                        "vfwsub.vv",
                                        "vfwadd.wv",
                                        "vfwsub.wv",
                                        "vfmul.vv",
                                        "vfdiv.vv",
                                        "vfwmul.vv",
                                        "vfmacc.vv",
                                        "vfnmacc.vv",
                                        "vfmsac.vv",
                                        "vfnmsac.vv",
                                        "vfmadd.vv",
                                        "vfnmadd.vv",
                                        "vfmsub.vv",
                                        "vfnmsub.vv",
                                        "vfwmacc.vv",
                                        "vfwnmacc.vv",
                                        "vfwmsac.vv",
                                        "vfwnmsac.vv",
                                        "vfsqrt.v",
                                        "vfrsqrt7.v",
                                        "vfrec7.v",
                                        "vfmin.vv",
                                        "vfmax.vv",
                                        "vfsgnj.vv",
                                        "vfsgnjn.vv",
                                        "vfsgnjx.vv",
                                        "vmfeq.vv",
                                        "vmfne.vv",
                                        "vmflt.vv",
                                        "vmfle.vv",
                                        "vfclass.v"
                                },
                                rvv_fp_convert = {
                                        "vfcvt.xu.f.v",
                                        "vfcvt.x.f.v",
                                        "vfcvt.rtz.xu.f.v",
                                        "vfcvt.rtz.x.f.v",
                                        "vfcvt.f.xu.v",
                                        "vfcvt.f.x.v",
                                },

				rvv_widened_src1_ops = {
					"vwaddu.wv", "vwaddu.wx", "vwsubu.wv", "vwsubu.wx",
					"vwadd.wv", "vwadd.wx", "vwsub.wv", "vwsub.wx",
					"vfwadd.wv", "vfwadd.wf", "vfwsub.wv", "vfwsub.wf",
					"vwredsumu.vs", "vwredsum.vs", "vfwredosum.vs", "vfwredusum.vs"
				},
				rvv_single_width_fractional_multiply = {
					"vsmul.vv", "vsmul.vx"
				},
                rvv_fixed_point_single_width_add_sub = {
                        "vsaddu.vv", "vsadd.vv", "vssubu.vv", "vssub.vv",
                        "vsaddu.vi", "vsadd.vi",
                        "vsaddu.vx", "vsadd.vx", "vssubu.vx", "vssub.vx"
                },
                rvv_fixed_point_single_width_averaging_add_sub = {
                        "vaaddu.vv", "vaadd.vv", "vasubu.vv", "vasub.vv",
                        "vaaddu.vx", "vaadd.vx", "vasubu.vx", "vasub.vx"
                },
                rvv_fixed_point_single_width_scaling_shift = {
                        "vssrl.vv", "vssra.vv",
                        "vssrl.vi", "vssra.vi",
                        "vssrl.vx", "vssra.vx"
                },
                rvv_fixed_point_clip = {
                        "vnclipu.wv", "vnclip.wv",
                        "vnclipu.wi", "vnclip.wi",
                        "vnclipu.wx", "vnclip.wx"
                },
                rvv_all_scalar_dest_ops = {
                        "vcpop.m",
                        "vfirst.m",
                        "vmv.x.s",
                        "vfmv.f.s",
                        "vsetvl",
                        "vsetivl",
                        "vsetivli"
                },
                rvv_vset = {
                        "vsetvl",
                        "vsetivl",
                        "vsetivli"
                        };

        std::vector<std::vector<std::string>> 
                                        rvv_int_arithmetic = {
                                                rvv_int_add_sub, rvv_int_widening_add_sub, rvv_int_sign_extension,  
                                                rvv_int_addwc_subwb, rvv_int_bitwise_logical, rvv_int_single_width_shift, 
                                                rvv_int_narrowing_right_shift, rvv_int_single_width_multiply, rvv_int_divide, 
                                                rvv_int_widening_multiply, rvv_int_single_width_mul_add, rvv_int_compare, 
                                                rvv_int_min_max,  rvv_int_merge,  rvv_int_move, rvv_int_widening_mul_add
                                        },
                                        rvv_all_mask = {
                                                rvv_mask_logical, rvv_mask_vcpop, rvv_mask_vfirst,
                                                rvv_mask_vmsbf, rvv_mask_vmsif, rvv_mask_vmsof,
                                                rvv_mask_viota, rvv_mask_vid
                                        },
                                        rvv_all_reduction = {
                                                rvv_int_single_width_red,rvv_int_widening_red,
                                                rvv_fp_single_width_red,rvv_fp_widening_red
                                        },
                                        rvv_all_loads = {
                                                rvv_unit_stride_load, 
                                                rvv_indexed_ordered_load,
                                                rvv_indexed_unordered_load,
                                                rvv_strided_load,
                                                rvv_whole_reg_load,
                                                rvv_load_fault_only_first,
                                                rvv_segmented_load,
                                                rvv_segmented_fault_first_load,
                                                rvv_ordered_indexed_segmented_load,
                                                rvv_unordered_indexed_segmented_load,
                                                rvv_strided_segmented_load
                                        },
                                        rvv_all_loads_excluding_fof = {
                                                rvv_unit_stride_load, 
                                                rvv_indexed_ordered_load,
                                                rvv_indexed_unordered_load,
                                                rvv_strided_load,
                                                rvv_whole_reg_load,
                                                rvv_segmented_load,
                                                rvv_ordered_indexed_segmented_load,
                                                rvv_unordered_indexed_segmented_load,
                                                rvv_strided_segmented_load
                                        },
                                        rvv_all_stores = {
                                                rvv_unit_stride_store,
                                                rvv_indexed_ordered_store,
                                                rvv_indexed_unordered_store,
                                                rvv_strided_store,
                                                rvv_whole_reg_store,
                                                rvv_segmented_store,
                                                rvv_ordered_indexed_segmented_store,
                                                rvv_unordered_indexed_segmented_store,
                                                rvv_strided_segmented_store
                                        },
                                        rvv_load_store = {
                                                rvv_unit_stride_load, rvv_unit_stride_store, 
                                                rvv_indexed_ordered_load, rvv_indexed_ordered_store,
                                                rvv_indexed_unordered_load, rvv_indexed_unordered_store,
                                                rvv_strided_load, rvv_strided_store,
                                                rvv_whole_reg_load, rvv_whole_reg_store,
                                                rvv_load_fault_only_first, rvv_segmented_fault_first_load,
                                                rvv_segmented_load, rvv_segmented_store,
                                                rvv_ordered_indexed_segmented_load, rvv_unordered_indexed_segmented_load,
                                                rvv_ordered_indexed_segmented_store, rvv_unordered_indexed_segmented_store,
                                                rvv_strided_segmented_load, rvv_strided_segmented_store
                                        },
                                        rvv_unit_strided_load_store = {
                                                rvv_unit_stride_load, rvv_unit_stride_store     
                                        },
                                        rvv_strided_load_store = {
                                                rvv_strided_load, rvv_strided_store
                                        },      
                                        rvv_indexed_load_store = {
                                                rvv_indexed_ordered_load, rvv_indexed_ordered_store,
                                                rvv_indexed_unordered_load, rvv_indexed_unordered_store,
                                                rvv_ordered_indexed_segmented_load, rvv_unordered_indexed_segmented_load,
                                                rvv_ordered_indexed_segmented_store, rvv_unordered_indexed_segmented_store
                                        },
                                        rvv_whole_reg_load_store = {
                                                rvv_whole_reg_load, rvv_whole_reg_store
                                        },
                                        rvv_vset_vars_ff_load_variants = {
                                                rvv_load_fault_only_first, rvv_segmented_fault_first_load, rvv_vset
                                        },
                                        rvv_segmented_load_store = {
                                                rvv_segmented_load, rvv_segmented_fault_first_load, rvv_segmented_store,
                                                rvv_ordered_indexed_segmented_load, rvv_unordered_indexed_segmented_load,
                                                rvv_ordered_indexed_segmented_store, rvv_unordered_indexed_segmented_store,
                                                rvv_strided_segmented_load, rvv_strided_segmented_store
                                        },
                                        rvv_strided_segmented_load_store = {
                                                rvv_strided_segmented_load, rvv_strided_segmented_store
                                        },
                                        rvv_all_fault_first_loads = {
                                                rvv_load_fault_only_first, rvv_segmented_fault_first_load
                                        },
                                        rvv_widening_excl_red = {
                                                rvv_int_widening_add_sub, rvv_int_widening_multiply, rvv_int_widening_mul_add,
                                                rvv_fp_widening_add_sub, rvv_fp_widening_multiply, rvv_fp_widening_mul_add,
                                                rvv_fp_widening_convert
                                        },
					rvv_widened_dest_ops = {
                                                rvv_int_widening_add_sub, rvv_int_widening_multiply, rvv_int_widening_mul_add,
                                                rvv_fp_widening_add_sub, rvv_fp_widening_multiply, rvv_fp_widening_mul_add,
                                                rvv_fp_widening_convert, rvv_int_widening_red, rvv_fp_widening_red,
						rvv_single_width_fractional_multiply
                                        },
                                        rvv_all_fixed_point_arithmetic = {
                                                rvv_fixed_point_single_width_add_sub, rvv_fixed_point_single_width_averaging_add_sub,
                                                rvv_single_width_fractional_multiply, rvv_fixed_point_single_width_scaling_shift,
                                                rvv_fixed_point_clip
                                        },
                                        rvv_all_fp = {
                                                rvv_fp_vv_variants, rvv_fp_vf_variants,
                                                rvv_fp_convert, rvv_fp_widening_convert,
                                                rvv_fp_narrowing_convert,rvv_fp_single_width_red,
                                                rvv_fp_widening_red,rvv_fp_scalar_move,
                                                rvv_fp_slideup, rvv_fp_slidedown 
                                        },
                                        rvv_all_narrowing_ops = {
                                                rvv_int_narrowing_right_shift, rvv_int_narrowing_clip,
                                                rvv_fp_narrowing_convert
                                        };


        std::map<std::string, std::vector<std::string>> vector_categories = {
                {"RVV_INT_ADD_SUB",               rvv_int_add_sub},
                {"RVV_INT_WIDENING_ADD_SUB",      rvv_int_widening_add_sub },
                {"RVV_INT_SIGN_EXTENSION",        rvv_int_sign_extension},
                {"RVV_INT_ADDWC_SUBWB",           rvv_int_addwc_subwb},
                {"RVV_INT_BITWISE_LOGICAL",       rvv_int_bitwise_logical},
                {"RVV_INT_SINGLE_WIDTH_SHIFT",    rvv_int_single_width_shift},
                {"RVV_INT_NARROWING_RIGHT_SHIFT", rvv_int_narrowing_right_shift},
                {"RVV_INT_NARROWING_CLIP",        rvv_int_narrowing_clip},
                {"RVV_INT_SINGLE_WIDTH_MULTIPLY", rvv_int_single_width_multiply},
                {"RVV_INT_DIVIDE",                rvv_int_divide},
                {"RVV_INT_WIDENING_MULTIPLY",     rvv_int_widening_multiply},
                {"RVV_INT_WIDENING_MUL_ADD",      rvv_int_widening_mul_add},
                {"RVV_INT_SINGLE_WIDTH_MUL_ADD",  rvv_int_single_width_mul_add},
                {"RVV_INT_COMPARE",               rvv_int_compare},
                {"RVV_INT_MIN_MAX",               rvv_int_min_max},
                {"RVV_INT_MERGE",                 rvv_int_merge},
                {"RVV_INT_MOVE",                  rvv_int_move},
                {"RVV_FIXED_POINT_SINGLE_WIDTH_ADD_SUB", rvv_fixed_point_single_width_add_sub},
                {"RVV_WIDENED_SRC1_OPS",          rvv_widened_src1_ops},
		        {"RVV_SINGLE_WIDTH_FRACTIONAL_MULTIPLY", rvv_single_width_fractional_multiply},
                {"RVV_FIXED_POINT_SINGLE_WIDTH_SCALING_SHIFT", rvv_fixed_point_single_width_scaling_shift},
                {"RVV_FIXED_POINT_SINGLE_WIDTH_AVERAGING_ADD_SUB", rvv_fixed_point_single_width_averaging_add_sub},
                {"RVV_FIXED_POINT_CLIP",          rvv_fixed_point_clip},
                {"RVV_MASK_LOGICAL",              rvv_mask_logical},
                {"RVV_MASK_VCPOP",                rvv_mask_vcpop},
                {"RVV_MASK_VFIRST",               rvv_mask_vfirst},
                {"RVV_MASK_VMSBF",                rvv_mask_vmsbf},
                {"RVV_MASK_VMSIF",                rvv_mask_vmsif},
                {"RVV_MASK_VMSOF",                rvv_mask_vmsof},
                {"RVV_MASK_VIOTA",                rvv_mask_viota},
                {"RVV_MASK_VID",                  rvv_mask_vid},
                {"RVV_INT_SCALAR_MOVE",           rvv_int_scalar_move},
                {"RVV_FP_SCALAR_MOVE",            rvv_fp_scalar_move},
                {"RVV_INT_SLIDEUP",               rvv_int_slideup},
                {"RVV_INT_SLIDEDOWN",             rvv_int_slidedown},
                {"RVV_FP_SLIDEUP",                rvv_fp_slideup},
                {"RVV_FP_SLIDEDOWN",              rvv_fp_slidedown},
                {"RVV_REG_GATHER",                rvv_reg_gather},
                {"RVV_REG_COMPRESS",              rvv_reg_compress},
                {"RVV_WHOLE_REG_MOVE",            rvv_whole_reg_move},
                {"RVV_INT_SINGLE_WIDTH_RED",      rvv_int_single_width_red},
                {"RVV_INT_WIDENING_RED",          rvv_int_widening_red},
                {"RVV_FP_SINGLE_WIDTH_RED",       rvv_fp_single_width_red},
                {"RVV_FP_WIDENING_RED",           rvv_fp_widening_red},
                {"RVV_FP_WIDENING_ADD_SUB",       rvv_fp_widening_add_sub},
                {"RVV_FP_WIDENING_MULTIPLY",      rvv_fp_widening_multiply},
                {"RVV_FP_WIDENING_MUL_ADD",       rvv_fp_widening_mul_add},
                {"RVV_FP_WIDENING_CONVERT",       rvv_fp_widening_convert},
                {"RVV_FP_NARROWING_CONVERT",      rvv_fp_narrowing_convert},
                {"RVV_FP_VF_VARIANTS",            rvv_fp_vf_variants},
                {"RVV_INT_VI_VARIANTS",           rvv_int_vi_variants},
                {"RVV_INT_VX_VARIANTS",           rvv_int_vx_variants},
                {"RVV_UNIT_STRIDE_LOAD",          rvv_unit_stride_load},
                {"RVV_UNIT_STRIDE_STORE",         rvv_unit_stride_store},
                {"RVV_UNIT_STRIDE_MASKED",        rvv_unit_stride_masked_load_store},
                {"RVV_INDEXED_ORDERED_LOAD",      rvv_indexed_ordered_load},
                {"RVV_INDEXED_ORDERED_STORE",     rvv_indexed_ordered_store}, 
                {"RVV_INDEXED_UNORDERED_LOAD",    rvv_indexed_unordered_load},
                {"RVV_INDEXED_UNORDERED_STORE",   rvv_indexed_unordered_store},
                {"RVV_STRIDED_LOAD",              rvv_strided_load},
                {"RVV_STRIDED_STORE",             rvv_strided_store},
                {"RVV_WHOLE_REG_LOAD",            rvv_whole_reg_load},
                {"RVV_WHOLE_REG_STORE",           rvv_whole_reg_store},
                {"RVV_FAULT_ONLY_FIRST",          rvv_load_fault_only_first},
                {"RVV_SEGMENTED_FAULT_FIRST_LOAD", rvv_segmented_fault_first_load},
                {"RVV_SEGMENTED_LOAD",            rvv_segmented_load},
                {"RVV_SEGMENTED_STORE",           rvv_segmented_store},
                {"RVV_ORDERED_INDEXED_SEGMENTED_LOAD", rvv_ordered_indexed_segmented_load},
                {"RVV_UNORDERED_INDEXED_SEGMENTED_LOAD", rvv_unordered_indexed_segmented_load},
                {"RVV_ORDERED_INDEXED_SEGMENTED_STORE", rvv_ordered_indexed_segmented_store},
                {"RVV_UNORDERED_INDEXED_SEGMENTED_STORE", rvv_unordered_indexed_segmented_store},
                {"RVV_STRIDED_SEGMENTED_LOAD", rvv_strided_segmented_load},
                {"RVV_STRIDED_SEGMENTED_STORE", rvv_strided_segmented_store},
                {"RVV_VSET",                      rvv_vset},
                {"RVV_ALL_SCALAR_DEST_OPS",       rvv_all_scalar_dest_ops},
                {"RVV_ALL_FIXED_POINT_ARITHMETIC",  concatenateVectors(rvv_all_fixed_point_arithmetic)},
                {"RVV_ALL_FP",                    concatenateVectors(rvv_all_fp)},
                {"RVV_ALL_LOADS",                 concatenateVectors(rvv_all_loads)},                       
                {"RVV_ALL_LOADS_EXCLUDING_FOF",   concatenateVectors(rvv_all_loads_excluding_fof)},
                {"RVV_ALL_STORES",                concatenateVectors(rvv_all_stores)},                       
                {"RVV_INT_ARITHMETIC",            concatenateVectors(rvv_int_arithmetic)},
                {"RVV_ALL_MASK",                  concatenateVectors(rvv_all_mask)},
                {"RVV_ALL_REDUCTION",             concatenateVectors(rvv_all_reduction)},
                {"RVV_LOAD_STORE",                concatenateVectors(rvv_load_store)},
                {"RVV_UNIT_STRIDED_LOAD_STORE",   concatenateVectors(rvv_unit_strided_load_store)},
                {"RVV_STRIDED_LOAD_STORE",        concatenateVectors(rvv_strided_load_store)},
                {"RVV_INDEXED_LOAD_STORE",        concatenateVectors(rvv_indexed_load_store)},
                {"RVV_WHOLE_REG_LOAD_STORE",      concatenateVectors(rvv_whole_reg_load_store)},
                {"RVV_VSET_VARS_FF_LOAD_VARIANTS",concatenateVectors(rvv_vset_vars_ff_load_variants)},
                {"RVV_SEGMENTED_LOAD_STORE",      concatenateVectors(rvv_segmented_load_store)},
                {"RVV_STRIDED_SEGMENTED_LOAD_STORE",   concatenateVectors(rvv_strided_segmented_load_store)},
                {"RVV_ALL_FAULT_FIRST_LOADS",      concatenateVectors(rvv_all_fault_first_loads)},
                {"RVV_WIDENING_EXCL_RED",   concatenateVectors(rvv_widening_excl_red)},
		{"RVV_WIDENED_DEST_OPS",   concatenateVectors(rvv_widened_dest_ops)},
                {"RVV_ALL_NARROWING_OPS",   concatenateVectors(rvv_all_narrowing_ops)},
        };
}
