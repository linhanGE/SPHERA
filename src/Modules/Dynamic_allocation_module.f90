!----------------------------------------------------------------------------------------------------------------------------------
! SPHERA (Smoothed Particle Hydrodynamics research software; mesh-less Computational Fluid Dynamics code).
! Copyright 2005-2015 (RSE SpA -formerly ERSE SpA, formerly CESI RICERCA, formerly CESI-; SPHERA has been authored for RSE SpA by 
!    Andrea Amicarelli, Antonio Di Monaco, Sauro Manenti, Elia Bon, Daria Gatti, Giordano Agate, Stefano Falappi, 
!    Barbara Flamini, Roberto Guandalini, David Zuccal�).
! Main numerical developments of SPHERA: 
!    Amicarelli et al. (2015,CAF), Amicarelli et al. (2013,IJNME), Manenti et al. (2012,JHE), Di Monaco et al. (2011,EACFM). 
! Email contact: andrea.amicarelli@rse-web.it

! This file is part of SPHERA.
! SPHERA is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
! SPHERA is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
! GNU General Public License for more details.
! You should have received a copy of the GNU General Public License
! along with SPHERA. If not, see <http://www.gnu.org/licenses/>.
!----------------------------------------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------------------------------------------
! Program unit: Dynamic_allocation_module           
! Description: Module to define dynamically allocated variables.                    
!----------------------------------------------------------------------------------------------------------------------------------

module Dynamic_allocation_module
use Hybrid_allocation_module
! Vertice(3,n_vertices): array of the geometrical vertices
double precision,          dimension(:,:), allocatable :: Vertice                  
type (TyBoundaryStretch),  dimension(:),   allocatable :: Tratto
type (TyZone),             dimension(:),   allocatable :: Partz
type (TyMedium),           dimension(:),   allocatable :: Med
integer(4),                dimension(:),   allocatable :: BoundaryVertex
type (TyBoundarySide),     dimension(:),   allocatable :: BoundarySide
type (TyBoundaryFace),     dimension(:),   allocatable :: BoundaryFace
type (TyCtlPoint),         dimension(:),   allocatable :: Control_Points
type (TyCtlLine),          dimension(:),   allocatable :: Control_Lines
type (TySection),          dimension(:),   allocatable :: Control_Sections
type (TyCtlPoint),         dimension(:),   allocatable :: Section_Points
type (TyParticle),         dimension(:),   allocatable :: Pg
type (Tytime_stage),       dimension(:),   allocatable :: ts0_pg
type(TyBoundaryConvexEdge),dimension(:),   allocatable :: BoundaryConvexEdge
! Icont(grid%nmax+1) contains the number of the first particle in each cell and
! the total number of particles.
! The particle are here ordered according to the cell order. The element values
! of this array monotonically increase. 
! NPartOrd(PARTICLEBUFFER) contains the particle IDs. The elements are ordered 
! as for Icont.
integer(4),                dimension(:),   allocatable :: Icont,NPartOrd,GCBFVector
! Array of the wall elements (DB-SPH)
type (TyParticle_w),       dimension(:),   allocatable :: Pg_w
! Arrays for ordering wall elements, according to the underliying mesh
integer(4),                dimension(:),   allocatable :: Icont_w,NPartOrd_w
! Array of the transported rigid solid bodies
type (body),               dimension(:),   allocatable :: body_arr
! Array of the body particles
type (body_particle),     dimension(:),    allocatable :: bp_arr
! Arrays for ordering body particles, according to the background mesh
integer(4),               dimension(:),    allocatable :: Icont_bp,NPartOrd_bp
integer(4),               dimension(:,:),  allocatable :: GCBFPointers
integer(4),               dimension(:),    allocatable :: BFaceList
! nPartIntorno(PARTICLEBUFFER): array of the number of the neighbouring 
! particles
integer(4),               dimension(:),    allocatable :: nPartIntorno
! PartIntorno(NMAXPARTJ*PARTICLEBUFFER): array of the indeces of the 
! neighbouring particles
integer(4),               dimension(:),    allocatable :: PartIntorno
! PartKernel(4,NMAXPARTJ*PARTICLEBUFFER):
! PartKernel(1,b): -|gradW_0b|/|r_0b|, gradW: kernel gradient (cubic spline);
!    Thus gradW = |gradW_0b| * (gradW_0b/|gradW_0b|) = - PartKernel*rag, 
!    rag=-(x_b-x_0) is aligned with gradW
! PartKernel(2,b): -|gradW_0b|/[|r_0b|(|r_0b|^2+eps^2)], cubic spline kernel
! PartKernel(3,b): -|gradW_0b|/|r_0b|, Gallati anti-cluster kernel, 
!                  used for pressure terms (SA-SPH) 
! PartKernel(4,b): W_0b: absolute value of the kernel cubic spline,
!                        used for interpolations and DB-SPH
! gradW vector is equal to -PartKernel(1 or 3,b)*rag_0b
double precision,         dimension(:,:),  allocatable :: PartKernel
! rag(3,NMAXPARTJ*PARTICLEBUFFER): 3D vector list of -r_0b=x_0-x_b,
! r_0b (vector distance between the computational particle and the neighbour)
double precision,         dimension(:,:),  allocatable :: rag  
! nPartIntorno_fw(PARTICLEBUFFER): array of the number of the neighbouring 
! wall particles 
integer(4),               dimension(:),    allocatable :: nPartIntorno_fw
! PartIntorno_fw(NMAXPARTJ*PARTICLEBUFFER): array of the indeces of the 
! neighbouring wall particles 
integer(4),               dimension(:),    allocatable :: PartIntorno_fw   
! Kernel function neighbouring array (wall neighbours), 
! kernel_fw(NMAXPARTJ*PARTICLEBUFFER)
double precision,         dimension(:,:),  allocatable :: kernel_fw
! Relative distances from wall particles: -r_0a, 
! rag_fw(components,NMAXPARTJ*PARTICLEBUFFER)
double precision,         dimension(:,:),  allocatable :: rag_fw  
! neighbouring arrays for body dynamics
! neighbouring arrays of the body particles 
! (body particle - fluid particle interactions; 
! fluid particles are treated as neighbours)
! nPartIntorno_bp_f(n_body_particles): array of the number of the neighbouring
! fluid particles to each body particle
integer(4),               dimension(:),    allocatable :: nPartIntorno_bp_f
! PartIntorno_bp_f(NMAXPARTJ*n_body_particles): array of the indeces of 
! the neighbouring fluid particles to each body particle
integer(4),               dimension(:),    allocatable :: PartIntorno_bp_f   
! Kernel derivative neighbouring array (fluid neighbours), 
! KerDer_bp_f_cub_spl(n_body_particles*NMAXPARTJ), cubic spline;
! KerDer_bp_f_cub_spl = -|gradW_bp_f|/|r_bp_f|
double precision,         dimension(:),    allocatable :: KerDer_bp_f_cub_spl 
! Kernel derivative neighbouring array (fluid neighbours), 
! KerDer_bp_f_Gal(n_body_particles*NMAXPARTJ), Gallati's kernel;
! KerDer_bp_f_Gal = -|gradW_bp_f|/|r_bp_f|
double precision,         dimension(:),    allocatable :: KerDer_bp_f_Gal 
! relative distances from fluid particles: -r_bp_f; 
! rag_bp_f(3,NMAXPARTJ*n_body_particles)
double precision,         dimension(:,:),  allocatable :: rag_bp_f  
! neighbouring arrays for inter-body impacts 
! (body_A particle - body_B particle interactions)
! list of surface body particles surf_body_part(n_surf_body_part)
integer(4),               dimension(:),    allocatable :: surf_body_part
! nPartIntorno_bp_bp(n_surf_body_part): array of the number of the neighbouring
! body particles, belonging to another body
integer(4),               dimension(:),    allocatable :: nPartIntorno_bp_bp
! PartIntorno_bp_bp(n_surf_body_part*NMAXPARTJ): array of the indeces of the 
! neighbouring body particles (of another body) 
integer(4),               dimension(:),    allocatable :: PartIntorno_bp_bp   
! relative distances from body particles (belonging to another body): -r_bp_bp;
! rag_bp_bp(3,NMAXPARTJ*n_surf_body_part)
double precision,         dimension(:,:),  allocatable :: rag_bp_bp  
! array of velocity impacts for body dynamics 
! impact_vel(n_surf_body_part x (n_bodies+n_boundaries))
double precision,         dimension(:,:),  allocatable :: impact_vel  
! Arrays to compute the table of integrals (SA-SPH)
integer(4),               dimension(:,:),  allocatable :: BoundaryDataPointer
type (TyBoundaryData),    dimension(:),    allocatable :: BoundaryDataTab
! Arrays to count in and outgoing particles for every medium
integer(4),               dimension(:),    allocatable :: OpCount,SpCount
integer(4),               dimension(:),    allocatable :: EpCount,EpOrdGrid
! Array to count fluid particles (but those with status="sol")
integer(4),               dimension(:),    allocatable :: Array_Flu
! Arrays 2D to detect the free surface in case of erosion model
! (store pl_imed, intliq_id, intsol_id) of every column.
integer(4),               dimension(:,:,:),allocatable :: ind_interfaces 
! Only in 3D: the 2D arrays of the maximum values of the fluid particle height
! (at the nodes of the grid columns) and the specific flow rate. 
real(kind=kind(1.d0)),    dimension(:),    allocatable :: Z_fluid_max,q_max  
end module
