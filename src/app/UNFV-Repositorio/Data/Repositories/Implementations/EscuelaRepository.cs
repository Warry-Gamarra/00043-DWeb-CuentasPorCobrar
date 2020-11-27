using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Tables;

namespace Data.Repositories.Implementations
{
    public class EscuelaRepository : IEscuelaRepository
    {
        public IEnumerable<TC_Escuela> GetByFac(string codFac)
        {
            IEnumerable<TC_Escuela> result;
            try
            {
                result = TC_Escuela.GetByFac(codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }

        public TC_Escuela GetByID(string codEsc, string codFac)
        {
            TC_Escuela result;
            try
            {
                result = TC_Escuela.GetByID(codEsc, codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }
    }
}
