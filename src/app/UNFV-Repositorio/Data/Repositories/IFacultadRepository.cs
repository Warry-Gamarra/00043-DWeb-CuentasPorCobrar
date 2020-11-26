using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IFacultadRepository
    {
        IEnumerable<TC_Facultad> GetAll();

        TC_Facultad GetByID(string C_CodFac);
    }
}
