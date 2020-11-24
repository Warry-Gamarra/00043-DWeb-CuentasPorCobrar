using Data.DTO;
using Data.Procedures;
using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IProgramaUnfvRepository
    {
        IEnumerable<TC_ProgramaUnfv> GetAll();

        ResponseData Create(TC_ProgramaUnfv programaUnfv);

        ResponseData Edit(TC_ProgramaUnfv programaUnfv);
    }
}
