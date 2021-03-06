      program write_nondimensional
      use cgns
c
c   Opens an existing CGNS file and adds the DataClass and
c   ReferenceState appropriate for a completely
c   NONDIMENSIONAL data set.
c
c   The CGNS grid file 'grid.cgns' must already exist
c   (for example, created using write_grid_str.f or
c   write_grid_unst.f).  In this case, the flow solution does
c   not need to be present.
c
c   This program uses the fortran convention that all
c   variables beginning with the letters i-n are integers,
c   by default, and all others are real
c
c   Example compilation for this program is (change paths if needed!):
c   Note: when using the cgns module file, you must use the SAME fortran compiler
c   used to compile CGNS (see make.defs file)
c   ...or change, for example, via environment "setenv FC ifort"
c
c   ifort -I ../.. -c write_nondimensional.f
c   ifort -o write_nondimensional write_nondimensional.o -L ../../lib -lcgns
c
c   (../../lib is the location where the compiled
c   library libcgns.a is located)
c
c   The following is no longer supported; now superceded by "use cgns":
c     include 'cgnslib_f.h'
c   Note Windows machines need to include cgnswin_f.h
c
      real*8 xmach,reue,xmv,xmc,rev,rel,renu,rho0,gamma,p0,c0,vm0,
     +  xlength0,vx,vy,vz
      integer(cgsize_t) nuse
c
      write(6,'('' Program write_nondimensional'')')
      if (CG_BUILD_64BIT) then
        write(6,'('' ...using 64-bit mode for particular integers'')')
      end if
c   define nondimensional parameters
      xmach=4.6d0
      reue=6000000.d0
      xmv=xmach
      xmc=1.d0
      rev=xmach
      rel=1.d0
      renu=xmach/reue
      rho0=1.d0
      gamma=1.4d0
      p0=1.d0/gamma
      c0=1.d0
      vm0=xmach/reue
      xlength0=1.d0
      vx=xmach
      vy=0.d0
      vz=0.d0
      nuse=1
c   WRITE NONDIMENSIONAL INFO
c   open CGNS file for modify
      call cg_open_f('grid.cgns',CG_MODE_MODIFY,index_file,ier)
      if (ier .ne. CG_OK) call cg_error_exit_f
c   we know there is only one base (real working code would check!)
      index_base=1
c   put DataClass under Base
      call cg_goto_f(index_file,index_base,ier,'end')
c   check first if a dataclass has already been written
      call cg_dataclass_read_f(idata,ier)
      if (ier .eq. 0) then
        write(6,'('' Error! DataClass already exists!'')')
        write(6,'(''   Re-make CGNS file without it and related info,'',
     +    '' then try again'')')
        stop
      else
        ier=0
      end if
      call cg_dataclass_write_f(NormalizedByUnknownDimensional,ier)
c   put ReferenceState under Base
      call cg_state_write_f('ReferenceQuantities',ier)
c   Go to ReferenceState node, write Mach array and its dataclass
      call cg_goto_f(index_file,index_base,ier,'ReferenceState_t',1,
     +  'end')
      call cg_array_write_f('Mach',RealDouble,1,nuse,xmach,ier)
      call cg_goto_f(index_file,index_base,ier,'ReferenceState_t',1,
     +  'DataArray_t',1,'end')
      call cg_dataclass_write_f(NondimensionalParameter,ier)
c   Go to ReferenceState node, write Reynolds array and its dataclass
      call cg_goto_f(index_file,index_base,ier,'ReferenceState_t',1,
     +  'end')
      call cg_array_write_f('Reynolds',RealDouble,1,nuse,reue,ier)
      call cg_goto_f(index_file,index_base,ier,'ReferenceState_t',1,
     +  'DataArray_t',2,'end')
      call cg_dataclass_write_f(NondimensionalParameter,ier)
c   Go to ReferenceState node to write reference quantities:
      call cg_goto_f(index_file,index_base,ier,'ReferenceState_t',1,
     +  'end')
c   First, write reference quantities that make up Mach and Reynolds:
c   Mach_Velocity
      call cg_array_write_f('Mach_Velocity',RealDouble,1,nuse,xmv,ier)
c   Mach_VelocitySound
      call cg_array_write_f('Mach_VelocitySound',RealDouble,
     +   1,nuse,xmc,ier)
c   Reynolds_Velocity
      call cg_array_write_f('Reynolds_Velocity',RealDouble,
     +   1,nuse,rev,ier)
c   Reynolds_Length
      call cg_array_write_f('Reynolds_Length',RealDouble,
     +   1,nuse,rel,ier)
c   Reynolds_ViscosityKinematic
      call cg_array_write_f('Reynolds_ViscosityKinematic',RealDouble,
     +   1,nuse,renu,ier)
c
c   Next, write flow field reference quantities:
c   Density
      call cg_array_write_f('Density',RealDouble,1,nuse,rho0,ier)
c   Pressure
      call cg_array_write_f('Pressure',RealDouble,1,nuse,p0,ier)
c   VelocitySound
      call cg_array_write_f('VelocitySound',RealDouble,1,nuse,c0,ier)
c   ViscosityMolecular
      call cg_array_write_f('ViscosityMolecular',RealDouble,
     +   1,nuse,vm0,ier)
c   LengthReference
      call cg_array_write_f('LengthReference',RealDouble,
     +   1,nuse,xlength0,ier)
c   VelocityX
      call cg_array_write_f('VelocityX',RealDouble,1,nuse,vx,ier)
c   VelocityY
      call cg_array_write_f('VelocityY',RealDouble,1,nuse,vy,ier)
c   VelocityZ
      call cg_array_write_f('VelocityZ',RealDouble,1,nuse,vz,ier)
c   close CGNS file
      call cg_close_f(index_file,ier)
      write(6,'('' Successfully wrote nondimensional info to file'',
     + '' grid.cgns'')')
      stop
      end
