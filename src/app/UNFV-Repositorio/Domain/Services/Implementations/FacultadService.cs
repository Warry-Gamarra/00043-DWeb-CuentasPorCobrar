using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Repositories;
using Domain.Entities;

namespace Domain.Services.Implementations
{
    public class FacultadService : IFacultadService
    {
        IFacultadRepository _facultadRepository;

        public FacultadService(IFacultadRepository facultadRepository)
        {
            _facultadRepository = facultadRepository;
        }

        public IEnumerable<FacultadDTO> GetAll()
        {
            IEnumerable<FacultadDTO> result;

            var facultades = _facultadRepository.GetAll();

            if (facultades == null)
            {
                result = new List<FacultadDTO>();
            }
            else
            {
                result = facultades.Select(a => Mapper.TC_Facultad_To_FacultadDTO(a));
            }

            return result;
        }

        public FacultadDTO GetByID(string codFac)
        {
            var facultad = _facultadRepository.GetByID(codFac);

            var result = (facultad == null) ? null : Mapper.TC_Facultad_To_FacultadDTO(facultad);

            return result;
        }
    }
}
