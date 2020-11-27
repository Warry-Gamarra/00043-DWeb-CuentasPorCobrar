using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Repositories;
using Domain.Entities;

namespace Domain.Services.Implementations
{
    public class EspecialidadService : IEspecialidadService
    {
        IEspecialidadRepository _especialidadRepository;

        public EspecialidadService(IEspecialidadRepository especialidadRepository)
        {
            _especialidadRepository = especialidadRepository;
        }

        public IEnumerable<EspecialidadDTO> GetByEsc(string codEsc, string codFac)
        {
            IEnumerable<EspecialidadDTO> result;

            var especialidades = _especialidadRepository.GetByEsc(codEsc, codFac);

            if (especialidades == null)
            {
                result = new List<EspecialidadDTO>();
            }
            else
            {
                result = especialidades.Select(e => Mapper.TC_EspecialidadToEspecialidadDTO(e));
            }

            return result;
        }

        public EspecialidadDTO GetByID(string codEsp, string codEsc, string codFac)
        {
            var especialidad = _especialidadRepository.GetByID(codEsp, codEsc, codFac);

            var result = (especialidad == null) ? null : Mapper.TC_EspecialidadToEspecialidadDTO(especialidad);

            return result;
        }
    }
}
