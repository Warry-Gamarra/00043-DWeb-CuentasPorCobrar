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
        IEspecialidadService _especialidadService;
        

        public ProgramaServiceFacade(
            IFacultadService facultadService,
            IEscuelaService escuelaService,
            IEspecialidadService especialidadService)
        {
            _facultadService = facultadService;
            _escuelaService = escuelaService;
            _especialidadService = especialidadService;
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

        public IEnumerable<EspecialidadModel> GetEspecialidadesByEsc(string codEsc, string codFac)
        {
            return _especialidadService.GetByEsc(codEsc, codFac).Select(e => Mapper.EspecialidadDTO_To_EspecialidadModel(e)); ;
        }

        public EspecialidadModel GetEspecialidadByID(string codEsp, string codEsc, string codFac)
        {
            var especialidadDTO = _especialidadService.GetByID(codEsp, codEsc, codFac);

            return Mapper.EspecialidadDTO_To_EspecialidadModel(especialidadDTO);
        }
    }
}