#include "types.h"
#include "dns_error.h"
#ifdef USE_MPI
#include "dns_const_mpi.h"
#endif

!########################################################################
!# HISTORY
!#
!# 2012/11/01 - J.P. Mellado
!#              Restructured into OPR_INTERPOLATE_* routines
!#
!########################################################################
!# DESCRIPTION
!#
!# Interpolate a 3d field from an original grid into a new one
!#
!# Based on splines library
!#
!########################################################################
SUBROUTINE OPR_INTERPOLATE(nx,ny,nz, nx_dst,ny_dst,nz_dst, &
     g, x_org,y_org,z_org, x_dst,y_dst,z_dst, u_org,u_dst, txc, isize_wrk3d, wrk3d)

  USE DNS_TYPES,  ONLY : grid_dt
  USE DNS_GLOBAL, ONLY : isize_txc_field
#ifdef USE_MPI
  USE DNS_CONSTANTS, ONLY : lfile
  USE DNS_MPI
#endif

  IMPLICIT NONE

#include "integers.h"

  TINTEGER nx,ny,nz, nx_dst,ny_dst,nz_dst, isize_wrk3d
  TYPE(grid_dt),                          INTENT(IN)    :: g(3)
  TREAL, DIMENSION(*),                    INTENT(IN)    :: x_org,y_org,z_org, x_dst,y_dst,z_dst
  TREAL, DIMENSION(nx*ny*nz),             INTENT(IN)    :: u_org
  TREAL, DIMENSION(nx_dst*ny_dst*nz_dst), INTENT(OUT)   :: u_dst
  TREAL, DIMENSION(isize_txc_field,*),    INTENT(INOUT) :: txc
  TREAL, DIMENSION(isize_wrk3d),          INTENT(INOUT) :: wrk3d

! -------------------------------------------------------------------

#ifdef USE_MPI
  TINTEGER id, npage
#endif

! ###################################################################
#ifdef USE_MPI
  IF ( ims_npro_i .GT. 1 ) THEN
     CALL IO_WRITE_ASCII(lfile,'Initialize MPI type 1 for Ox interpolation.')
     id = DNS_MPI_I_AUX1
     npage = nz*ny
     CALL DNS_MPI_TYPE_I(ims_npro_i, nx,     npage, i1, i1, i1, i1, &
          ims_size_i(id), ims_ds_i(1,id), ims_dr_i(1,id), ims_ts_i(1,id), ims_tr_i(1,id))

     CALL IO_WRITE_ASCII(lfile,'Initialize MPI type 2 for Ox interpolation.')
     id = DNS_MPI_I_AUX2
     npage = nz*ny
     CALL DNS_MPI_TYPE_I(ims_npro_i, nx_dst, npage, i1, i1, i1, i1, &
          ims_size_i(id), ims_ds_i(1,id), ims_dr_i(1,id), ims_ts_i(1,id), ims_tr_i(1,id))
  ENDIF

  IF ( ims_npro_k .GT. 1 ) THEN
     CALL IO_WRITE_ASCII(lfile,'Initialize MPI type 1 for Oz interpolation.')
     id = DNS_MPI_K_AUX1
     npage = nx_dst*ny_dst
     CALL DNS_MPI_TYPE_K(ims_npro_k, nz,     npage, i1, i1, i1, i1, &
          ims_size_k(id), ims_ds_k(1,id), ims_dr_k(1,id), ims_ts_k(1,id), ims_tr_k(1,id))

     CALL IO_WRITE_ASCII(lfile,'Initialize MPI type 2 for Oz interpolation.')
     id = DNS_MPI_K_AUX2
     npage = nx_dst*ny_dst
     CALL DNS_MPI_TYPE_K(ims_npro_k, nz_dst, npage, i1, i1, i1, i1, &
          ims_size_k(id), ims_ds_k(1,id), ims_dr_k(1,id), ims_ts_k(1,id), ims_tr_k(1,id))

  ENDIF
#endif

! #######################################################################
! Always interpolating along Ox
  IF ( g(1)%size .GT. 1 ) THEN
     CALL OPR_INTERPOLATE_X(nx,    ny,    nz, nx_dst, &
          g(1)%periodic, g(1)%scale, x_org,x_dst, u_org,   txc(1,1), txc(1,2),txc(1,3), isize_wrk3d, wrk3d)
  ELSE
     txc(1:nx*ny*nz,1) = u_org(1:nx*ny*nz)
  ENDIF

  IF ( g(2)%size .GT. 1 ) THEN
     CALL OPR_INTERPOLATE_Y(nx_dst,ny,    nz, ny_dst, &
          g(2)%periodic, g(2)%scale, y_org,y_dst, txc(1,1),txc(1,2), txc(1,3),txc(1,4), isize_wrk3d, wrk3d)
  ELSE
     txc(1:nx_dst*ny*nz,2) = txc(1:nx_dst*ny*nz,1)
  ENDIF

  IF ( g(3)%size .GT. 1 ) THEN
     CALL OPR_INTERPOLATE_Z(nx_dst,ny_dst,nz, nz_dst, &
          g(3)%periodic, g(3)%scale, z_org,z_dst, txc(1,2),u_dst,    txc(1,1),txc(1,3), isize_wrk3d, wrk3d)
  ELSE
     u_dst(1:nx_dst*ny_dst*nz_dst) = txc(1:nx_dst*ny_dst*nz_dst,2)
  ENDIF
  
  RETURN
END SUBROUTINE OPR_INTERPOLATE
