using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IEscuelaRepository
    {
        IEnumerable<TC_Escuela> GetAll();

        IEnumerable<TC_Escuela> GetByFac(string codFac);

        TC_Escuela GetByID(string codEsc, string C_CodFac);
    }
}
