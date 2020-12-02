using Data.DTO;
using Data.Repositories;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ProgramaUnfvService : IProgramaUnfvService
    {
        IProgramaUnfvRepository _programaRepository;
        ICarreraProfesionalRepository _carreraProfesionalRepository;

        public ProgramaUnfvService(
            IProgramaUnfvRepository programaRepository,
            ICarreraProfesionalRepository carreraProfesionalRepository)
        {
            _programaRepository = programaRepository;
            _carreraProfesionalRepository = carreraProfesionalRepository;
        }

        public ServiceResponse Create(ProgramaUnfvEntity programaUnfvEntity)
        {
            throw new NotImplementedException();
        }

        public ServiceResponse Edit(ProgramaUnfvEntity programaUnfvEntity)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<ProgramaUnfv> GetAll()
        {
            throw new NotImplementedException();
        }
    }
}
