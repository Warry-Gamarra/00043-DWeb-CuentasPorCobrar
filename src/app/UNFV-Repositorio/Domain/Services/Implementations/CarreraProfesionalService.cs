using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Repositories;
using Domain.Entities;

namespace Domain.Services.Implementations
{
    public class CarreraProfesionalService : ICarreraProfesionalService
    {
        ICarreraProfesionalRepository _carreraProfesionalRepository;

        public CarreraProfesionalService(ICarreraProfesionalRepository especialidadRepository)
        {
            _carreraProfesionalRepository = especialidadRepository;
        }

        public IEnumerable<CarreraProfesionalDTO> GetByFac(string codFac)
        {
            IEnumerable<CarreraProfesionalDTO> result;

            var carrerasProfesionales = _carreraProfesionalRepository.GetByFac(codFac);

            if (carrerasProfesionales == null)
            {
                result = new List<CarreraProfesionalDTO>();
            }
            else
            {
                result = carrerasProfesionales.Select(c => Mapper.VW_CarreraProfesional_To_CarreraProfesionalDTO(c));
            }

            return result;
        }

        public IEnumerable<CarreraProfesionalDTO> GetByEsc(string codEsc, string codFac)
        {
            IEnumerable<CarreraProfesionalDTO> result;

            var carrerasProfesionales = _carreraProfesionalRepository.GetByEsc(codEsc, codFac);

            if (carrerasProfesionales == null)
            {
                result = new List<CarreraProfesionalDTO>();
            }
            else
            {
                result = carrerasProfesionales.Select(c => Mapper.VW_CarreraProfesional_To_CarreraProfesionalDTO(c));
            }

            return result;
        }

        public CarreraProfesionalDTO GetByID(string codRc)
        {
            var carreraProfesional = _carreraProfesionalRepository.GetByID(codRc);

            var result = (carreraProfesional == null) ? null : Mapper.VW_CarreraProfesional_To_CarreraProfesionalDTO(carreraProfesional);

            return result;
        }
    }
}
