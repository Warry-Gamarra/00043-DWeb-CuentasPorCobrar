using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class ServiceFacade : IServiceFacade
    {
        IFacultadService _facultadService;
        IEscuelaService _escuelaService;
        IEspecialidadService _especialidadService;

        public ServiceFacade(
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
            var facultades = _facultadService.GetAll();

            var result = facultades.Select(f => Mapper.FacultadDTO_To_FacultadModel(f));

            return result;
        }

        public FacultadModel GetFacultadByID(string codFac)
        {
            var facultad = _facultadService.GetByID(codFac);

            var result = Mapper.FacultadDTO_To_FacultadModel(facultad);

            return result;
        }

        public IEnumerable<EscuelaModel> GetEscuelasByFac(string codFac)
        {
            var escuelas = _escuelaService.GetByFac(codFac);

            var result = escuelas.Select(e => Mapper.EscuelaDTO_To_EscuelaModel(e));

            return result;
        }

        public EscuelaModel GetEscuelaByID(string codEsc, string codFac)
        {
            var escuela = _escuelaService.GetByID(codEsc, codFac);

            var result = Mapper.EscuelaDTO_To_EscuelaModel(escuela);

            return result;
        }

        public IEnumerable<EspecialidadModel> GetEspecialidadesByEsc(string codEsc, string codFac)
        {
            var especialidades = _especialidadService.GetByEsc(codEsc, codFac);

            var result = especialidades.Select(e => Mapper.EspecialidadDTO_To_EspecialidadModel(e));

            return result;
        }

        public EspecialidadModel GetEspecialidadByID(string codEsp, string codEsc, string codFac)
        {
            var especialidad = _especialidadService.GetByID(codEsp, codEsc, codFac);

            var result = Mapper.EspecialidadDTO_To_EspecialidadModel(especialidad);

            return result;
        }
    }
}