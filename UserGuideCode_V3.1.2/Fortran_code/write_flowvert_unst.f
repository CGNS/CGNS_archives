      program write_flowvert_unst
c
c   Opens an existing CGNS file that contains a simple 3-D 
c   unstructured grid, and adds a flow solution (at VERTICES)
c   to it.
c
c   The CGNS grid file 'grid.cgns' must already exist
c   (created using write_grid_unst.f)
c   Note that, other than the dimensions of the variables
c   r and p, this program is essentially identical to that for 
c   writing flow solutions to a structured zone:  
c   write_flowvert_str.f
c
c   This program uses the fortran convention that all
c   variables beginning with the letters i-n are integers,
c   by default, and all others are real
c
c   Example compilation for this program is (change paths!):
c
c   ifort -I ../CGNS_CVS/cgnslib_2.5 -c write_flowvert_unst.f
c   ifort -o write_flowvert_unst write_flowvert_unst.o -L ../CGNS_CVS/cgnslib_2.5/LINUX -lcgns
c
c   (../CGNS_CVS/cgnslib_2.5/LINUX/ is the location where the compiled
c   library libcgns.a is located)
c
c   cgnslib_f.h file must be located in directory specified by -I during compile:
      include 'cgnslib_f.h'
c
      real*8 r(21*17*9),p(21*17*9)
      character solname*32
c
c   create fake flow solution AT VERTICES for simple example:
      ni=21
      nj=17
      nk=9
      iset=0
      do k=1,nk
        do j=1,nj
          do i=1,ni
            iset=iset+1
            r(iset)=float(i-1)
            p(iset)=float(j-1)
          enddo
        enddo
      enddo
      write(6,'('' created simple 3-D rho and p flow solution'')')
c
c   WRITE FLOW SOLUTION TO EXISTING CGNS FILE
c   open CGNS file for modify
      call cg_open_f('grid.cgns',CG_MODE_MODIFY,index_file,ier)
      if (ier .ne. CG_OK) call cg_error_exit_f
c   we know there is only one base (real working code would check!)
      index_base=1
c   we know there is only one zone (real working code would check!)
      index_zone=1
c   define flow solution node name (user can give any name)
      solname = 'FlowSolution'
c   create flow solution node
      call cg_sol_write_f(index_file,index_base,index_zone,solname,
     + Vertex,index_flow,ier)
c   write flow solution (user must use SIDS-standard names here)
      call cg_field_write_f(index_file,index_base,index_zone,index_flow,
     + RealDouble,'Density',r,index_field,ier)
      call cg_field_write_f(index_file,index_base,index_zone,index_flow,
     + RealDouble,'Pressure',p,index_field,ier)
c   close CGNS file
      call cg_close_f(index_file,ier)
      write(6,'('' Successfully added flow solution data to file'', 
     + '' grid.cgns (unstructured)'')')
      write(6,'(''   Note:  if the original CGNS file already had'',
     + '' a FlowSolution_t node,'')')
      write(6,'(''          it has been overwritten'')')
      stop
      end
