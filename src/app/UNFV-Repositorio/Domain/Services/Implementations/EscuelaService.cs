using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Repositories;
using Domain.Entities;

namespace Domain.Services.Implementations
{
    public class EscuelaService : IEscuelaService
    {
        IEscuelaRepository _escuelaRepository;

        public EscuelaService(IEscuelaRepository escuelaRepository)
        {
            _escuelaRepository = escuelaRepository;
        }

        public IEnumerable<EscuelaDTO> GetAll()
        {
            IEnumerable<EscuelaDTO> result;

            var escuelas = _escuelaRepository.GetAll();

            if (escuelas == null)
            {
                result = new List<EscuelaDTO>();
            }
            else
            {
                result = escuelas.Select(e => Mapper.TC_EscuelaToEscuelaDTO(e));
            }

            return result;
        }

        public IEnumerable<EscuelaDTO> GetByFac(string codFac)
        {
            IEnumerable<EscuelaDTO> result;

            var escuelas = _escuelaRepository.GetByFac(codFac);

            if (escuelas == null)
            {
                result = new List<EscuelaDTO>();
            }
            else
            {
                result = escuelas.Select(e => Mapper.TC_EscuelaToEscuelaDTO(e));
            }

            return result;
        }

        public EscuelaDTO GetByID(string codEsc, string codFac)
        {
            var escuela = _escuelaRepository.GetByID(codEsc, codFac);

            var result = (escuela == null) ? null : Mapper.TC_EscuelaToEscuelaDTO(escuela);

            return result;
        }
    }
}
