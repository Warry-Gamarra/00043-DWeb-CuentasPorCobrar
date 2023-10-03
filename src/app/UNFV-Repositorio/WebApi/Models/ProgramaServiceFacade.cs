using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class ProgramaServiceFacade : IProgramaServiceFacade
    {
        IFacultadService _facultadService;
        IEscuelaService _escuelaService;
        ICarreraProfesionalService _especialidadService;
        IProgramaUnfvService _programaUnfvService;

        public ProgramaServiceFacade(
            IFacultadService facultadService,
            IEscuelaService escuelaService,
            ICarreraProfesionalService CarreraProfesionalService,
            IProgramaUnfvService programaUnfvService)
        {
            _facultadService = facultadService;
            _escuelaService = escuelaService;
            _especialidadService = CarreraProfesionalService;
            _programaUnfvService = programaUnfvService;
        }

        public IEnumerable<FacultadModel> GetFacultades()
        {
            return _facultadService.GetAll().Select(f => Mapper.FacultadDTO_To_FacultadModel(f));
        }

        public FacultadModel GetFacultadByID(string codFac)
        {
            var facultadDTO = _facultadService.GetByID(codFac);

            return Mapper.FacultadDTO_To_FacultadModel(facultadDTO);
        }

        public IEnumerable<EscuelaModel> GetEscuelasByFac(string codFac)
        {
            return _escuelaService.GetByFac(codFac).Select(e => Mapper.EscuelaDTO_To_EscuelaModel(e));
        }

        public EscuelaModel GetEscuelaByID(string codEsc, string codFac)
        {
            var escuelaDTO = _escuelaService.GetByID(codEsc, codFac);

            return Mapper.EscuelaDTO_To_EscuelaModel(escuelaDTO);
        }

        public IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionalesByFac(string codFac)
        {
            return _especialidadService.GetByFac(codFac).Select(e => Mapper.CarreraProfesionalDTO_To_CarreraProfesionalModel(e));
        }

        public IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionalesByEsc(string codEsc, string codFac)
        {
            return _especialidadService.GetByEsc(codEsc, codFac).Select(e => Mapper.CarreraProfesionalDTO_To_CarreraProfesionalModel(e));
        }

        public CarreraProfesionalModel GetCarreraProfesionalByID(string codRc)
        {
            var carreraProfesionalDTO = _especialidadService.GetByID(codRc);

            return Mapper.CarreraProfesionalDTO_To_CarreraProfesionalModel(carreraProfesionalDTO);
        }

        public ServiceResponse GrabarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID)
        {
            var programaUnfvEntity = Mapper.ProgramaUnfvModel_To_ProgramaUnfvEntity(programaUnfvModel, currentUserID);

            return _programaUnfvService.Create(programaUnfvEntity);
        }

        public ServiceResponse EditarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID)
        {
            var programaUnfvEntity = Mapper.ProgramaUnfvModel_To_ProgramaUnfvEntity(programaUnfvModel, currentUserID);

            return _programaUnfvService.Edit(programaUnfvEntity);
        }

        public IEnumerable<ProgramaUnfvModel> GetProgramasUnfv()
        {
            return _programaUnfvService.GetAll().Select(p => Mapper.ProgramaUnfvDTO_To_ProgramaUnfvModel(p)); ;
        }

        public ProgramaUnfvModel GetProgramaUnfvByID(string codProg)
        {
            var programaUnfvDTO = _programaUnfvService.GetByID(codProg);

            return Mapper.ProgramaUnfvDTO_To_ProgramaUnfvModel(programaUnfvDTO);
        }

        public ProgramaUnfvModel GetProgramaUnfvByCodRc(string codRc)
        {
            var programaUnfvDTO = _programaUnfvService.GetByCodRc(codRc);

            return Mapper.ProgramaUnfvDTO_To_ProgramaUnfvModel(programaUnfvDTO);
        }

        public IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionales()
        {
            return _especialidadService.GetAll().Select(e => Mapper.CarreraProfesionalDTO_To_CarreraProfesionalModel(e));
        }
    }
}