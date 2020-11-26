using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IEspecialidadRepository
    {
        IEnumerable<TC_Especialidad> GetAll();

        IEnumerable<TC_Especialidad> GetByEsc(string codEsc, string codFac);

        TC_Especialidad GetByID(string codEsp, string codEsc, string codFac);
    }
}
