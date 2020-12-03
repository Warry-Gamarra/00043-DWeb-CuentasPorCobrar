using Data.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IProgramaUnfvService
    {
        ServiceResponse Create(ProgramaUnfvEntity programaUnfvEntity);

        ServiceResponse Edit(ProgramaUnfvEntity programaUnfvEntity);

        IEnumerable<ProgramaUnfvDTO> GetAll();

        ProgramaUnfvDTO GetByID(string codProg);

        ProgramaUnfvDTO GetByCodRc(string codRc);
    }
}
