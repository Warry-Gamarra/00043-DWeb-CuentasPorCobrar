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
    public interface ICarreraProfesionalRepository
    {
        ResponseData Create(TI_CarreraProfesional carreraProfesional);

        ResponseData Edit(TI_CarreraProfesional carreraProfesional);

        IEnumerable<TI_CarreraProfesional> GetAll();
    }
}
