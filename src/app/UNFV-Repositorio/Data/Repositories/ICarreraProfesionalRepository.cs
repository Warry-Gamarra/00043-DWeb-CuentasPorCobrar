using Data.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface ICarreraProfesionalRepository
    {
        IEnumerable<VW_CarreraProfesional> GetByFac(string codFac);

        IEnumerable<VW_CarreraProfesional> GetByEsc(string codEsc, string codFac);

        VW_CarreraProfesional GetByID(string codRc);
    }
}
