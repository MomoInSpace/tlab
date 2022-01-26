#include "types.h"
#include "dns_const.h"

SUBROUTINE OPR_PARTIAL1(nlines, bcs, g, u,result, wrk2d)

  USE TLAB_TYPES, ONLY : grid_dt

  IMPLICIT NONE

  TINTEGER,                        INTENT(IN)    :: nlines ! # of lines to be solved
  TINTEGER, DIMENSION(2),          INTENT(IN)    :: bcs    ! BCs at xmin (1) and xmax (2):
                                                           !     0 biased, non-zero
                                                           !     1 forced to zero
  TYPE(grid_dt),                   INTENT(IN)    :: g
  TREAL, DIMENSION(nlines*g%size), INTENT(IN)    :: u
  TREAL, DIMENSION(nlines*g%size), INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),        INTENT(INOUT) :: wrk2d

! -------------------------------------------------------------------
  TINTEGER ip

! ###################################################################
  IF ( g%periodic ) THEN
     SELECT CASE( g%mode_fdm )

     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C1N4P_RHS(g%size,nlines, u, result)

     CASE( FDM_COM6_JACOBIAN, FDM_COM6_DIRECT ) ! Direct = Jacobian because uniform grid
        CALL FDM_C1N6P_RHS(g%size,nlines, u, result)

     CASE( FDM_COM8_JACOBIAN )
        CALL FDM_C1N8P_RHS(g%size,nlines, u, result)

     END SELECT

     CALL TRIDPSS(g%size,nlines, g%lu1(1,1),g%lu1(1,2),g%lu1(1,3),g%lu1(1,4),g%lu1(1,5), result,wrk2d)

! -------------------------------------------------------------------
  ELSE
     SELECT CASE( g%mode_fdm )

     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C1N4_RHS(g%size,nlines, bcs(1),bcs(2), u, result)

     CASE( FDM_COM6_JACOBIAN )
        CALL FDM_C1N6_RHS(g%size,nlines, bcs(1),bcs(2), u, result)

     CASE( FDM_COM8_JACOBIAN )
        CALL FDM_C1N8_RHS(g%size,nlines, bcs(1),bcs(2), u, result)

     CASE( FDM_COM6_DIRECT   ) ! Not yet implemented
        CALL FDM_C1N6_RHS(g%size,nlines, bcs(1),bcs(2), u, result)

     END SELECT

     ip = (bcs(1) + bcs(2)*2)*3
     CALL TRIDSS(g%size,nlines, g%lu1(1,ip+1),g%lu1(1,ip+2),g%lu1(1,ip+3), result)

  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL1

! ###################################################################
! ###################################################################
SUBROUTINE OPR_PARTIAL2(nlines, bcs, g, u,result, wrk2d,wrk3d)

  USE TLAB_TYPES, ONLY : grid_dt

  IMPLICIT NONE

  TINTEGER,                        INTENT(IN)    :: nlines ! # of lines to be solved
  TINTEGER, DIMENSION(2,*),        INTENT(IN)    :: bcs    ! BCs at xmin (1,*) and xmax (2,*):
                                                           !     0 biased, non-zero
                                                           !     1 forced to zero
  TYPE(grid_dt),                   INTENT(IN)    :: g
  TREAL, DIMENSION(nlines,g%size), INTENT(IN)    :: u
  TREAL, DIMENSION(nlines,g%size), INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),        INTENT(INOUT) :: wrk2d
  TREAL, DIMENSION(nlines,g%size), INTENT(INOUT) :: wrk3d  ! First derivative, in case needed

  ! --- local declarations -------------------------------------------------------------------

  TINTEGER is !,ip
  PARAMETER(is=-1)

  ! ### end of declarations ##################################################################

  CALL OPR_PARTIAL2D(is,nlines, bcs, g, u,result, wrk2d,wrk3d)
! ! ###################################################################
! ! Check whether to calculate 1. order derivative
!   IF ( .NOT. g%uniform ) THEN
!      IF ( g%mode_fdm .eq. FDM_COM4_JACOBIAN .OR. &
!           g%mode_fdm .eq. FDM_COM6_JACOBIAN .OR. &
!           g%mode_fdm .eq. FDM_COM8_JACOBIAN      ) THEN
!         CALL OPR_PARTIAL1(nlines, bcs, g, u,wrk3d, wrk2d)
!      ENDIF
!   ENDIF
!
! ! ###################################################################
!   IF ( g%periodic ) THEN
!      SELECT CASE( g%mode_fdm )
!
!      CASE( FDM_COM4_JACOBIAN )
!         CALL FDM_C2N4P_RHS(g%size,nlines, u, result)
!
!      CASE( FDM_COM6_JACOBIAN, FDM_COM6_DIRECT ) ! Direct = Jacobian because uniform grid
!        ! CALL FDM_C2N6P_RHS(g%size,nlines, u, result)
!        CALL FDM_C2N6HP_RHS(g%size,nlines, u, result)
!
!      CASE( FDM_COM8_JACOBIAN )                  ! Not yet implemented
!         CALL FDM_C2N6P_RHS(g%size,nlines, u, result)
!
!      END SELECT
!
!      CALL TRIDPSS(g%size,nlines, g%lu2(1,1),g%lu2(1,2),g%lu2(1,3),g%lu2(1,4),g%lu2(1,5), result,wrk2d)
!
! ! -------------------------------------------------------------------
!   ELSE
!      SELECT CASE( g%mode_fdm )
!
!      CASE( FDM_COM4_JACOBIAN )
!         IF ( g%uniform ) THEN
!            CALL FDM_C2N4_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
!         ELSE ! Not yet implemented
!         ENDIF
!      CASE( FDM_COM6_JACOBIAN )
!         IF ( g%uniform ) THEN
!           CALL FDM_C2N6H_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
!         ELSE
!           CALL FDM_C2N6HNJ_RHS(g%size,nlines, bcs(1,2),bcs(2,2), g%jac, u, wrk3d, result)
!         ENDIF
!
!      CASE( FDM_COM8_JACOBIAN ) ! Not yet implemented; defaulting to 6. order
!         IF ( g%uniform ) THEN
!            CALL FDM_C2N6_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
!         ELSE
!            CALL FDM_C2N6NJ_RHS(g%size,nlines, bcs(1,2),bcs(2,2), g%jac, u, wrk3d, result)
!         ENDIF
!
!      CASE( FDM_COM6_DIRECT   )
!         CALL FDM_C2N6ND_RHS(g%size,nlines, g%lu2(1,4), u, result)
!
!      END SELECT

!      ip = (bcs(1,2) + bcs(2,2)*2)*3
!      CALL TRIDSS(g%size,nlines, g%lu2(1,ip+1),g%lu2(1,ip+2),g%lu2(1,ip+3), result)

!   ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL2

! ###################################################################################
! ### First Derivative
! ### Second Derivative includes
! ###       factor 1    (is=-1)
! ###       viscosity   (is= 0)
! ###       diffusivity (is= 1,inb_scal)
SUBROUTINE OPR_PARTIAL2D(is,nlines, bcs, g, u,result, wrk2d,wrk3d)

  USE TLAB_TYPES, ONLY : grid_dt

  IMPLICIT NONE

  TINTEGER,                        INTENT(IN)    :: is     ! scalar index; if 0, then velocity
  TINTEGER,                        INTENT(IN)    :: nlines ! # of lines to be solved
  TINTEGER, DIMENSION(2,*),        INTENT(IN)    :: bcs    ! BCs at xmin (1,*) and xmax (2,*):
                                                           !     0 biased, non-zero
                                                           !     1 forced to zero
  TYPE(grid_dt),                   INTENT(IN)    :: g
  TREAL, DIMENSION(nlines,g%size), INTENT(IN)    :: u
  TREAL, DIMENSION(nlines,g%size), INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),        INTENT(INOUT) :: wrk2d
  TREAL, DIMENSION(nlines,g%size), INTENT(INOUT) :: wrk3d  ! First derivative

  TREAL, DIMENSION(:,:), POINTER :: lu2_p


! -------------------------------------------------------------------
  TINTEGER ip

  ! ###################################################################
  ! always calculate first derivative as this routine is normally called from opr_burgers
  ! ###################################################################
  CALL OPR_PARTIAL1(nlines, bcs, g, u,wrk3d, wrk2d)

  IF ( is .GE. 0 ) THEN
     IF ( g%periodic ) THEN
        lu2_p => g%lu2d(:,is*5+1:)  ! periodic;     including diffusivity/viscosity
     ELSE
        lu2_p => g%lu2d(:,is*3+1:)  ! non-periodic; including diffusivity/viscosity
     ENDIF
  ELSE
     IF ( g%periodic ) THEN
        lu2_p => g%lu2(:,1:)        ! periodic;     plain derivative
     ELSE
        ip = (bcs(1,2)+bcs(2,2)*2)*3! non-periodic; plain derivative
        lu2_p => g%lu2(:,ip+1:)
     ENDIF
  ENDIF


  ! ###################################################################
  IF ( g%periodic ) THEN
     SELECT CASE( g%mode_fdm )

     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C2N4P_RHS(g%size,nlines, u, result)

     CASE( FDM_COM6_JACOBIAN, FDM_COM6_DIRECT ) ! Direct = Jacobian because uniform grid
        CALL FDM_C2N6HP_RHS(g%size,nlines, u, result)

     CASE( FDM_COM8_JACOBIAN )                  ! Not yet implemented
        CALL FDM_C2N6P_RHS(g%size,nlines, u, result)

     END SELECT

     CALL TRIDPSS(g%size,nlines, lu2_p(1,1),lu2_p(1,2),lu2_p(1,3),lu2_p(1,4),lu2_p(1,5), result,wrk2d)

  ! -------------------------------------------------------------------
  ELSE
     SELECT CASE( g%mode_fdm )

     CASE( FDM_COM4_JACOBIAN )
        IF ( g%uniform ) THEN
           CALL FDM_C2N4_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
        ELSE ! Not yet implemented
        ENDIF

     CASE( FDM_COM6_JACOBIAN )
        IF ( g%uniform ) THEN
          CALL FDM_C2N6H_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
        ELSE
           ! need first derivative from above
          CALL FDM_C2N6HNJ_RHS(g%size,nlines, bcs(1,2),bcs(2,2), g%jac, u, wrk3d, result)
        ENDIF

     CASE( FDM_COM8_JACOBIAN ) ! Not yet implemented; defaulting to 6. order
        IF ( g%uniform ) THEN
           CALL FDM_C2N6_RHS  (g%size,nlines, bcs(1,2),bcs(2,2),        u,        result)
        ELSE
           ! Need first derivative from above
           CALL FDM_C2N6NJ_RHS(g%size,nlines, bcs(1,2),bcs(2,2), g%jac, u, wrk3d, result)
        ENDIF

     CASE( FDM_COM6_DIRECT   )
        CALL FDM_C2N6ND_RHS(g%size,nlines, g%lu2(1,4), u, result)

     END SELECT

     CALL TRIDSS(g%size,nlines, lu2_p(1,1),lu2_p(1,2),lu2_p(1,3), result)

  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL2D

! ###################################################################
#include "dns_error.h"
! ###################################################################

SUBROUTINE OPR_PARTIAL0_INT(dir, nlines, bcs, g, u,result, wrk2d, wrk3d)

  USE TLAB_TYPES,     ONLY : grid_dt
  USE TLAB_PROCS,     ONLY : TLAB_STOP, TLAB_WRITE_ASCII
  USE TLAB_CONSTANTS, ONLY : efile

  IMPLICIT NONE
 
  TINTEGER,                            INTENT(IN)    :: dir    ! scalar direction flag
                                                               !     0 'vp' --> vel. to pre. 
                                                               !     1 'pv' --> pre. to vel.
  TINTEGER,                            INTENT(IN)    :: nlines ! # of lines to be solved
  TINTEGER, DIMENSION(2),              INTENT(IN)    :: bcs    ! BCs at xmin (1) and xmax (2):
                                                               !     0 biased, non-zero
                                                               !     1 forced to zero
  TYPE(grid_dt),                       INTENT(IN)    :: g
  TREAL, DIMENSION(nlines,g%size),     INTENT(IN)    :: u
  TREAL, DIMENSION(nlines,g%size),     INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),            INTENT(INOUT) :: wrk2d
  TREAL, DIMENSION(nlines,(g%size+1)), INTENT(INOUT) :: wrk3d  ! non-periodic case
 
! -------------------------------------------------------------------
  TINTEGER                                           :: ip, i, jk
! ###################################################################
! pure interpolation from one grid to another   
  IF ( dir .EQ. 0 ) THEN ! direction: vel. --> pre.
    IF ( g%periodic ) THEN
      SELECT CASE( g%mode_fdm )        
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN )
        CALL FDM_C0INTVP6P_RHS(g%size,nlines, u, result)
      END SELECT
      CALL TRIDPSS(g%size,nlines, g%lu0i(1,1),g%lu0i(1,2),g%lu0i(1,3),g%lu0i(1,4),g%lu0i(1,5), result,wrk2d)
    ! -------------------------------------------------------------------
    ELSEIF ( .NOT. g%periodic .AND. g%name .EQ. 'y' ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN ) ! hybrid case
        CALL FDM_C0INTVP6_RHS(g%size,g%size-1,nlines, u, result(:,:g%size-1))
      END SELECT
      ip = 0
      CALL TRIDSS(g%size-1,nlines, g%lu0i(1,ip+1),g%lu0i(1,ip+2),g%lu0i(1,ip+3), result(:,:g%size-1))
      wrk3d(:,1) = u(:,1); wrk3d(:,g%size+1) = u(:,g%size)
      DO i = 1,g%size-1
        DO jk = 1,nlines
          wrk3d(jk,i+1) = result(jk,i)
        ENDDO
      ENDDO
    ELSE
      CALL TLAB_WRITE_ASCII(efile, 'OPR_PARTIAL0_INT. Non-periodic case only implemented for y-direction.')
      CALL TLAB_STOP(DNS_ERROR_NOTIMPL)
    ENDIF
  ! =====================================================================
  ELSE IF ( dir .EQ. 1 ) THEN ! direction: pre. --> vel.
    IF ( g%periodic ) THEN
      SELECT CASE( g%mode_fdm )        
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN )
        CALL FDM_C0INTPV6P_RHS(g%size,nlines, u, result)
      END SELECT
      CALL TRIDPSS(g%size,nlines, g%lu0i(1,1),g%lu0i(1,2),g%lu0i(1,3),g%lu0i(1,4),g%lu0i(1,5), result,wrk2d)
    ! -------------------------------------------------------------------
    ELSEIF ( .NOT. g%periodic .AND. g%name .EQ. 'y' ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN ) ! hybrid case
        CALL FDM_C0INTPV6_RHS(g%size,g%size-1,nlines, u(:,:g%size-1), result)
      END SELECT
      ip = 3
      CALL TRIDSS(g%size,nlines, g%lu0i(1,ip+1),g%lu0i(1,ip+2),g%lu0i(1,ip+3), result)
    ELSE
      CALL TLAB_WRITE_ASCII(efile, 'OPR_PARTIAL0_INT. Non-periodic case only implemented for y-direction.')
      CALL TLAB_STOP(DNS_ERROR_NOTIMPL)
    ENDIF
  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL0_INT

! ###################################################################
! ###################################################################

SUBROUTINE OPR_PARTIAL1_INT(dir, nlines, bcs, g, u,result, wrk2d, wrk3d)

  USE TLAB_TYPES,     ONLY : grid_dt
  USE TLAB_PROCS,     ONLY : TLAB_STOP, TLAB_WRITE_ASCII
  USE TLAB_CONSTANTS, ONLY : efile

  IMPLICIT NONE
 
  TINTEGER,                            INTENT(IN)    :: dir    ! scalar direction flag
                                                               !     0 'vp' --> vel. to pre. 
                                                               !     1 'pv' --> pre. to vel.
  TINTEGER,                            INTENT(IN)    :: nlines ! # of lines to be solved
  TINTEGER, DIMENSION(2),              INTENT(IN)    :: bcs    ! BCs at xmin (1) and xmax (2):
                                                               !     0 biased, non-zero
                                                               !     1 forced to zero
  TYPE(grid_dt),                       INTENT(IN)    :: g
  TREAL, DIMENSION(nlines,g%size),     INTENT(IN)    :: u
  TREAL, DIMENSION(nlines,g%size),     INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),            INTENT(INOUT) :: wrk2d
  TREAL, DIMENSION(nlines,(g%size+1)), INTENT(INOUT) :: wrk3d  ! non-periodic case

! -------------------------------------------------------------------
  TINTEGER                                           :: ip, i, jk
! ###################################################################
! 1st interpolatory derivative from one grid to another   
  IF ( dir .EQ. 0 ) THEN  ! direction: vel. --> pre.
    IF ( g%periodic ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM6_JACOBIAN )
        CALL FDM_C1INTVP6P_RHS(g%size,nlines, u, result)
      END SELECT
      CALL TRIDPSS(g%size,nlines, g%lu1i(1,1),g%lu1i(1,2),g%lu1i(1,3),g%lu1i(1,4),g%lu1i(1,5), result,wrk2d)
    ! -------------------------------------------------------------------
    ELSEIF ( .NOT. g%periodic .AND. g%name .EQ. 'y' ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN )
        CALL FDM_C1INTVP6_RHS(g%size,g%size-1,nlines, u, result(:,:g%size-1))
      END SELECT
      ip = 0
      CALL TRIDSS(g%size-1,nlines, g%lu1i(1,ip+1),g%lu1i(1,ip+2),g%lu1i(1,ip+3), result(:,:g%size-1))
      CALL OPR_PARTIAL1(nlines, bcs, g, u,wrk3d, wrk2d) ! hybrid case, deriv. at boundary points
      wrk3d(:,g%size+1) = wrk3d(:,g%size)
      DO i = 1,g%size-1
        DO jk = 1,nlines
          wrk3d(jk,i+1) = result(jk,i)
        ENDDO
      ENDDO
    ELSE
      CALL TLAB_WRITE_ASCII(efile, 'OPR_PARTIAL1_INT. Non-periodic case only implemented for y-direction.')
      CALL TLAB_STOP(DNS_ERROR_NOTIMPL)
    ENDIF
  ! =====================================================================
  ELSE IF ( dir .EQ. 1 ) THEN ! direction: pre. --> vel.
    IF ( g%periodic ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN )
        CALL FDM_C1INTPV6P_RHS(g%size,nlines, u, result)
      END SELECT
      CALL TRIDPSS(g%size,nlines, g%lu1i(1,1),g%lu1i(1,2),g%lu1i(1,3),g%lu1i(1,4),g%lu1i(1,5), result,wrk2d)
    ! -------------------------------------------------------------------
    ELSEIF ( .NOT. g%periodic .AND. g%name .EQ. 'y' ) THEN
      SELECT CASE( g%mode_fdm )
      CASE( FDM_COM4_JACOBIAN, FDM_COM6_JACOBIAN, FDM_COM6_DIRECT, FDM_COM8_JACOBIAN )
        CALL FDM_C1INTPV6_RHS(g%size,g%size-1,nlines, u(:,:g%size-1), result)
      END SELECT
      ip = 3
      CALL TRIDSS(g%size,nlines, g%lu1i(1,ip+1),g%lu1i(1,ip+2),g%lu1i(1,ip+3), result)
    ELSE
      CALL TLAB_WRITE_ASCII(efile, 'OPR_PARTIAL1_INT. Non-periodic case only implemented for y-direction.')
      CALL TLAB_STOP(DNS_ERROR_NOTIMPL)
    ENDIF
  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL1_INT
 
! ###################################################################
! ###################################################################

#ifdef USE_MPI
#include "dns_const_mpi.h"
#endif

!########################################################################
!# Routines for different specific directions
!########################################################################
SUBROUTINE OPR_PARTIAL_X(type, nx,ny,nz, bcs, g, u, result, tmp1, wrk2d,wrk3d)

  USE TLAB_TYPES,    ONLY : grid_dt
#ifdef USE_MPI
  USE TLAB_MPI_VARS, ONLY : ims_npro_i
  USE TLAB_MPI_VARS, ONLY : ims_size_i, ims_ds_i, ims_dr_i, ims_ts_i, ims_tr_i
  USE TLAB_MPI_PROCS
#endif

  IMPLICIT NONE

#include "integers.h"

  TINTEGER,                   INTENT(IN)    :: type      ! OPR_P1           1.order derivative
                                                         ! OPR_P2           2.order derivative
                                                         ! OPR_P2_P1        2. and 1.order derivatives (1. in tmp1)
                                                         ! OPR_P0_INT_VP/PV interpolation              (vel.<->pre.)
                                                         ! OPR_P1_INT_VP/PV 1.order int. derivative    (vel.<->pre.)
  TINTEGER,                   INTENT(IN)    :: nx,ny,nz  ! array sizes
  TINTEGER, DIMENSION(2,*),   INTENT(IN)    :: bcs       ! BCs at xmin (1,*) and xmax (2,*)
  TYPE(grid_dt),              INTENT(IN)    :: g
  TREAL, DIMENSION(nx*ny*nz), INTENT(IN)    :: u
  TREAL, DIMENSION(nx*ny*nz), INTENT(OUT)   :: result
  TREAL, DIMENSION(nx*(ny+1)*nz), INTENT(INOUT) :: tmp1, wrk3d
  TREAL, DIMENSION(ny*nz),    INTENT(INOUT) :: wrk2d

  TARGET u, tmp1, result, wrk3d

! -------------------------------------------------------------------
  TINTEGER nyz

  TREAL, DIMENSION(:), POINTER :: p_a, p_b, p_c, p_d

#ifdef USE_MPI
  TINTEGER, PARAMETER :: id = TLAB_MPI_I_PARTIAL
#endif

! ###################################################################
! -------------------------------------------------------------------
! MPI transposition
! -------------------------------------------------------------------
#ifdef USE_MPI
  IF ( ims_npro_i .GT. 1 ) THEN
     CALL TLAB_MPI_TRPF_I(u, result, ims_ds_i(1,id), ims_dr_i(1,id), ims_ts_i(1,id), ims_tr_i(1,id))
     p_a => result
     p_b => wrk3d
     p_c => result
     p_d => tmp1
     nyz = ims_size_i(id)
  ELSE
#endif
     p_a => u
     p_b => result
     IF ( type .EQ. OPR_P2_P1 ) THEN
        p_c => tmp1
        p_d => wrk3d
     ELSE
        p_c => wrk3d
        p_d => tmp1
     ENDIF
     nyz = ny*nz
#ifdef USE_MPI
  ENDIF
#endif

! -------------------------------------------------------------------
! Local transposition: make x-direction the last one
! -------------------------------------------------------------------
#ifdef USE_ESSL
  CALL DGETMO       (p_a, g%size, g%size, nyz,    p_b, nyz)
#else
  CALL DNS_TRANSPOSE(p_a, g%size, nyz,    g%size, p_b, nyz)
#endif

! ###################################################################
  SELECT CASE( type )

  CASE( OPR_P2 )
     CALL OPR_PARTIAL2(nyz, bcs, g, p_b,p_c, wrk2d,p_d)

  CASE( OPR_P1 )
     CALL OPR_PARTIAL1(nyz, bcs, g, p_b,p_c, wrk2d    )

  CASE( OPR_P2_P1 )
     CALL OPR_PARTIAL2(nyz, bcs, g, p_b,p_c, wrk2d,p_d)

! Check whether we need to calculate the 1. order derivative
     IF ( g%uniform .OR. g%mode_fdm .EQ. FDM_COM6_DIRECT ) THEN
        CALL OPR_PARTIAL1(nyz, bcs, g, p_b, p_d, wrk2d)
     ENDIF
  
  CASE( OPR_P0_INT_VP )
     CALL OPR_PARTIAL0_INT(i0, nyz, bcs, g, p_b,p_c, wrk2d,p_c)

  CASE( OPR_P0_INT_PV )
     CALL OPR_PARTIAL0_INT(i1, nyz, bcs, g, p_b,p_c, wrk2d,p_c)

  CASE( OPR_P1_INT_VP )
     CALL OPR_PARTIAL1_INT(i0, nyz, bcs, g, p_b,p_c, wrk2d,p_c)

  CASE( OPR_P1_INT_PV )
     CALL OPR_PARTIAL1_INT(i1, nyz, bcs, g, p_b,p_c, wrk2d,p_c)

  END SELECT

! ###################################################################
! Put arrays back in the order in which they came in
#ifdef USE_ESSL
  CALL DGETMO       (p_c, nyz, nyz,    g%size, p_b, g%size)
#else
  CALL DNS_TRANSPOSE(p_c, nyz, g%size, nyz,    p_b, g%size)
#endif

  IF ( type .EQ. OPR_P2_P1 ) THEN
#ifdef USE_ESSL
  CALL DGETMO       (p_d, nyz, nyz,    g%size, p_c, g%size)
#else
  CALL DNS_TRANSPOSE(p_d, nyz, g%size, nyz,    p_c, g%size)
#endif
  ENDIF

#ifdef USE_MPI
  IF ( ims_npro_i .GT. 1 ) THEN
     IF ( type .EQ. OPR_P2_P1 ) THEN ! only if you really want first derivative back
        CALL TLAB_MPI_TRPB_I(p_c, tmp1, ims_ds_i(1,id), ims_dr_i(1,id), ims_ts_i(1,id), ims_tr_i(1,id))
     ENDIF
     CALL TLAB_MPI_TRPB_I(p_b, result, ims_ds_i(1,id), ims_dr_i(1,id), ims_ts_i(1,id), ims_tr_i(1,id))
  ENDIF
#endif

  NULLIFY(p_a,p_b,p_c,p_d)

  RETURN
END SUBROUTINE OPR_PARTIAL_X

!########################################################################
!########################################################################
SUBROUTINE OPR_PARTIAL_Z(type, nx,ny,nz, bcs, g, u, result, tmp1, wrk2d,wrk3d)

  USE TLAB_TYPES, ONLY : grid_dt
#ifdef USE_MPI
  USE TLAB_MPI_VARS, ONLY : ims_npro_k
  USE TLAB_MPI_VARS, ONLY : ims_size_k, ims_ds_k, ims_dr_k, ims_ts_k, ims_tr_k
  USE TLAB_MPI_PROCS
#endif

  IMPLICIT NONE

#include "integers.h"

  TINTEGER,                   INTENT(IN)    :: type      ! OPR_P1           1.order derivative
                                                         ! OPR_P2           2.order derivative
                                                         ! OPR_P2_P1        2. and 1.order derivatives (1. in tmp1)
                                                         ! OPR_P0_INT_VP/PV interpolation              (vel.<->pre.)
                                                         ! OPR_P1_INT_VP/PV 1.order int. derivative    (vel.<->pre.)
  TINTEGER,                   INTENT(IN)    :: nx,ny,nz  ! array sizes
  TINTEGER, DIMENSION(2,*),   INTENT(IN)    :: bcs       ! BCs at xmin (1,*) and xmax (2,*)
  TYPE(grid_dt),              INTENT(IN)    :: g
  TREAL, DIMENSION(nx*ny*nz), INTENT(IN)    :: u
  TREAL, DIMENSION(nx*ny*nz), INTENT(OUT)   :: result
  TREAL, DIMENSION(nx*(ny+1)*nz), INTENT(INOUT) :: tmp1, wrk3d
  TREAL, DIMENSION(nx*ny),    INTENT(INOUT) :: wrk2d

  TARGET u, tmp1, result, wrk3d

! -------------------------------------------------------------------
  TINTEGER nxy

  TREAL, DIMENSION(:), POINTER :: p_a, p_b, p_c

#ifdef USE_MPI
  TINTEGER, PARAMETER :: id = TLAB_MPI_K_PARTIAL
#endif

! ###################################################################
  IF ( g%size .EQ. 1 ) THEN ! Set to zero in 2D case
     result = C_0_R
     IF ( type .EQ. OPR_P2_P1 ) tmp1 = C_0_R

  ELSE
! ###################################################################
! -------------------------------------------------------------------
! MPI Transposition
! -------------------------------------------------------------------
#ifdef USE_MPI
  IF ( ims_npro_k .GT. 1 ) THEN
     CALL TLAB_MPI_TRPF_K(u, result, ims_ds_k(1,id), ims_dr_k(1,id), ims_ts_k(1,id), ims_tr_k(1,id))
     p_a => result
     IF ( type .EQ. OPR_P2_P1 ) THEN
        p_b => tmp1
        p_c => wrk3d
     ELSE
        p_b => wrk3d
        p_c => tmp1
     ENDIF
     nxy = ims_size_k(id)
 ELSE
#endif
    p_a => u
    p_b => result
    p_c => tmp1
    nxy = nx*ny
#ifdef USE_MPI
  ENDIF
#endif

! ###################################################################
  SELECT CASE( type )

  CASE( OPR_P2 )
     CALL OPR_PARTIAL2(nxy, bcs, g, p_a,p_b, wrk2d,p_c)

  CASE( OPR_P1 )
     CALL OPR_PARTIAL1(nxy, bcs, g, p_a,p_b, wrk2d    )

  CASE( OPR_P2_P1 )
     CALL OPR_PARTIAL2(nxy, bcs, g, p_a,p_b, wrk2d,p_c)

! Check whether we need to calculate the 1. order derivative
     IF ( g%uniform .OR. g%mode_fdm .EQ. FDM_COM6_DIRECT ) THEN
        CALL OPR_PARTIAL1(nxy, bcs, g, p_a,p_c, wrk2d)
     ENDIF
  
  CASE( OPR_P0_INT_VP )
     CALL OPR_PARTIAL0_INT(i0, nxy, bcs, g, p_a,p_b, wrk2d,p_c)
 
  CASE( OPR_P0_INT_PV )
     CALL OPR_PARTIAL0_INT(i1, nxy, bcs, g, p_a,p_b, wrk2d,p_c)

  CASE( OPR_P1_INT_VP )
     CALL OPR_PARTIAL1_INT(i0, nxy, bcs, g, p_a,p_b, wrk2d,p_c)

  CASE( OPR_P1_INT_PV )
     CALL OPR_PARTIAL1_INT(i1, nxy, bcs, g, p_a,p_b, wrk2d,p_c)

  END SELECT

! ###################################################################
! Put arrays back in the order in which they came in
#ifdef USE_MPI
  IF ( ims_npro_k .GT. 1 ) THEN
     CALL TLAB_MPI_TRPB_K(p_b, result, ims_ds_k(1,id), ims_dr_k(1,id), ims_ts_k(1,id), ims_tr_k(1,id))
     IF ( type .EQ. OPR_P2_P1 ) THEN
        CALL TLAB_MPI_TRPB_K(p_c, tmp1, ims_ds_k(1,id), ims_dr_k(1,id), ims_ts_k(1,id), ims_tr_k(1,id))
     ENDIF
  ENDIF
#endif

  NULLIFY(p_a,p_b,p_c)

  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL_Z

!########################################################################
!########################################################################
SUBROUTINE OPR_PARTIAL_Y(type, nx,ny,nz, bcs, g, u, result, tmp1, wrk2d,wrk3d)

  USE TLAB_TYPES, ONLY : grid_dt
#ifdef USE_MPI
  USE TLAB_MPI_VARS
#endif

  IMPLICIT NONE

#include "integers.h"

  TINTEGER,                       INTENT(IN)    :: type      ! OPR_P1           1.order derivative
                                                             ! OPR_P2           2.order derivative
                                                             ! OPR_P2_P1        2. and 1.order derivatives (1. in tmp1)
                                                             ! OPR_P0_INT_VP/PV interpolation              (vel.<->pre.)
                                                             ! OPR_P1_INT_VP/PV 1.order int. derivative    (vel.<->pre.)
                                                             ! only non-periodic 'vp'-case is stored in tmp1 
  TINTEGER,                       INTENT(IN)    :: nx,ny,nz  ! array sizes
  TINTEGER, DIMENSION(2,*),       INTENT(IN)    :: bcs       ! BCs at xmin (1,*) and xmax (2,*)
  TYPE(grid_dt),                  INTENT(IN)    :: g
  TREAL, DIMENSION(nx*ny*nz),     INTENT(IN)    :: u
  TREAL, DIMENSION(nx*ny*nz),     INTENT(OUT)   :: result
  TREAL, DIMENSION(nx*(ny+1)*nz), INTENT(INOUT) :: tmp1, wrk3d ! extended size for interpolatory (hybrid) schemes
                                                               ! non-perdiodic interpolated fields are stored here
  TREAL, DIMENSION(nx*nz),        INTENT(INOUT) :: wrk2d

  TARGET u, tmp1, result, wrk3d

! -------------------------------------------------------------------
  TINTEGER nxy, nxy_int, nxz, nxyz, nxyz_int
  TREAL, DIMENSION(:), POINTER :: p_a, p_b, p_c

! ###################################################################
  IF ( g%size .EQ. 1 ) THEN ! Set to zero in 2D case
     result = C_0_R
     IF ( type .EQ. OPR_P2_P1 ) tmp1 = C_0_R

  ELSE
! ###################################################################
  nxz      = nx*nz
  nxy      = nx*ny
  nxyz     = nx*ny*nz
! for non-peridic 'vp'-case 
  nxy_int  = nx*(ny+1)
  nxyz_int = nx*(ny+1)*nz

! -------------------------------------------------------------------
! Local transposition: Make y direction the last one
! -------------------------------------------------------------------
  IF ( nz .EQ. 1 ) THEN
     p_a => u
     p_b => result
     p_c => tmp1
  ELSE
#ifdef USE_ESSL
     CALL DGETMO       (u, nxy, nxy, nz, result, nz)
#else
     CALL DNS_TRANSPOSE(u, nxy, nz, nxy, result, nz)
#endif
     p_a => result
     IF ( type .EQ. OPR_P2_P1 ) THEN
        p_b =>  tmp1(:nxyz)
        p_c => wrk3d(:nxyz)
     ELSEIF ( type .EQ. OPR_P0_INT_VP .OR. &
              type .EQ. OPR_P0_INT_PV .OR. &
              type .EQ. OPR_P1_INT_VP .OR. &
              type .EQ. OPR_P1_INT_PV      ) THEN
        p_b =>  tmp1(:nxyz_int) 
        p_c => wrk3d(:nxyz_int)
     ELSE
        p_b => wrk3d(:nxyz)
        p_c =>  tmp1(:nxyz)
     ENDIF
  ENDIF

! ###################################################################
  SELECT CASE( type )

  CASE( OPR_P2 )
     CALL OPR_PARTIAL2(nxz, bcs, g, p_a,p_b, wrk2d,p_c)

  CASE( OPR_P1 )
     CALL OPR_PARTIAL1(nxz, bcs, g, p_a,p_b, wrk2d    )

  CASE( OPR_P2_P1 )
     CALL OPR_PARTIAL2(nxz, bcs, g, p_a,p_b, wrk2d,p_c)

! Check whether we need to calculate the 1. order derivative
     IF ( g%uniform .OR. g%mode_fdm .EQ. FDM_COM6_DIRECT ) THEN
        CALL OPR_PARTIAL1(nxz, bcs, g, p_a,p_c, wrk2d)
     ENDIF
  
  CASE( OPR_P0_INT_VP )
     CALL OPR_PARTIAL0_INT(i0, nxz, bcs, g, p_a,p_b, wrk2d,p_c)
 
  CASE( OPR_P0_INT_PV )
     CALL OPR_PARTIAL0_INT(i1, nxz, bcs, g, p_a,p_b, wrk2d,p_c)
 
  CASE( OPR_P1_INT_VP )
     CALL OPR_PARTIAL1_INT(i0, nxz, bcs, g, p_a,p_b, wrk2d,p_c)
 
  CASE( OPR_P1_INT_PV )
     CALL OPR_PARTIAL1_INT(i1, nxz, bcs, g, p_a,p_b, wrk2d,p_c)

  END SELECT

! ###################################################################
! Put arrays back in the order in which they came in
  IF ( nz .GT. 1 ) THEN
#ifdef USE_ESSL
     CALL DGETMO       (p_b, nz, nz, nxy, result, nxy)
#else
     CALL DNS_TRANSPOSE(p_b, nz, nxy, nz, result, nxy)
#endif
     IF ( type .EQ. OPR_P2_P1 ) THEN
#ifdef USE_ESSL
        CALL DGETMO       (p_c, nz, nz, nxy, tmp1, nxy)
#else
        CALL DNS_TRANSPOSE(p_c, nz, nxy, nz, tmp1, nxy)
#endif
     ELSEIF ( .NOT. g%periodic .AND.       &
            ( type .EQ. OPR_P0_INT_VP .OR. &
              type .EQ. OPR_P1_INT_VP      )) THEN
#ifdef USE_ESSL
        CALL DGETMO       (p_c, nz, nz, nxy_int, tmp1, nxy_int)
#else
        CALL DNS_TRANSPOSE(p_c, nz, nxy_int, nz, tmp1, nxy_int)
#endif
     ENDIF
  ENDIF

  NULLIFY(p_a,p_b,p_c)

  ENDIF

  RETURN
END SUBROUTINE OPR_PARTIAL_Y