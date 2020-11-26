using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Tables;

namespace Data.Repositories.Implementations
{
    public class FacultadRepository : IFacultadRepository
    {
        public IEnumerable<TC_Facultad> GetAll()
        {
            IEnumerable<TC_Facultad> result;
            try
            {
                result = TC_Facultad.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }

        public TC_Facultad GetByID(string C_CodFac)
        {
            TC_Facultad result;
            try
            {
                result = TC_Facultad.GetByID(C_CodFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }
    }
}
