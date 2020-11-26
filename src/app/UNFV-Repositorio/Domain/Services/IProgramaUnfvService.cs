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
        ResponseData Create(ProgramaUnfvEntity programaUnfvEntity);

        ResponseData Edit(ProgramaUnfvEntity programaUnfvEntity);

        IEnumerable<ProgramaUnfv> GetAll();
    }
}
