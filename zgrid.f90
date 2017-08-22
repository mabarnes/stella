module zgrid

  implicit none

  public :: init_zgrid, finish_zgrid
  public :: nzed, ntgrid, nperiod
  public :: theta
  public :: delthet
  public :: shat_zero

  private

  integer :: nzed, ntgrid, nperiod
  real :: shat_zero
  real, dimension (:), allocatable :: theta, delthet

  logical :: zgridinit = .false.

contains

  subroutine init_zgrid

    use mp, only: proc0
    use constants, only: pi

    implicit none

    integer :: i

    if (zgridinit) return
    zgridinit = .true.

    if (proc0) then
       call read_parameters
    end if
    call broadcast_parameters

    if (.not.allocated(theta)) allocate (theta(-ntgrid:ntgrid))
    if (.not.allocated(delthet)) allocate (delthet(-ntgrid:ntgrid))

    theta = (/ (i*pi/real(nzed/2), i=-ntgrid, ntgrid ) /)
    delthet(:ntgrid-1) = theta(-ntgrid+1:) - theta(:ntgrid-1)
    delthet(ntgrid) = delthet(-ntgrid)

  end subroutine init_zgrid

  subroutine read_parameters

    use file_utils, only: input_unit_exist

    implicit none

    integer :: in_file
    logical :: exist

    namelist /zgrid_parameters/ nzed, nperiod, shat_zero

    nzed = 32
    nperiod = 1
    ! set minimum shat value below which we assume
    ! periodic BC
    shat_zero = 1.e-5

    in_file = input_unit_exist("zgrid_parameters", exist)
    if (exist) read (unit=in_file, nml=zgrid_parameters)

    ntgrid = nzed/2 + (nperiod-1)*nzed

  end subroutine read_parameters

  subroutine broadcast_parameters

    use mp, only: broadcast

    implicit none

    call broadcast (nzed)
    call broadcast (ntgrid)
    call broadcast (nperiod)
    call broadcast (shat_zero)

  end subroutine broadcast_parameters

  subroutine finish_zgrid

    implicit none

    if (allocated(theta)) deallocate (theta)
    if (allocated(delthet)) deallocate (delthet)

    zgridinit = .false.

  end subroutine finish_zgrid

end module zgrid
