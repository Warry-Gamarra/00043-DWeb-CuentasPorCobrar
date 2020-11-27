using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Tables;

namespace Data.Repositories.Implementations
{
    public class EspecialidadRepository : IEspecialidadRepository
    {
        public IEnumerable<TC_Especialidad> GetByEsc(string codEsc, string codFac)
        {
            IEnumerable<TC_Especialidad> result;
            try
            {
                result = TC_Especialidad.GetByEsc(codEsc, codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }

        public TC_Especialidad GetByID(string codEsp, string codEsc, string codFac)
        {
            TC_Especialidad result;
            try
            {
                result = TC_Especialidad.GetByID(codEsp, codEsc, codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }
    }
}
