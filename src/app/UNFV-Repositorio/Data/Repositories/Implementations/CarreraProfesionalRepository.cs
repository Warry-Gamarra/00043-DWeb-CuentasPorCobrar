using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Views;

namespace Data.Repositories.Implementations
{
    public class CarreraProfesionalRepository : ICarreraProfesionalRepository
    {
        public IEnumerable<VW_CarreraProfesional> GetByEsc(string codEsc, string codFac)
        {
            IEnumerable<VW_CarreraProfesional> result;
            try
            {
                result = VW_CarreraProfesional.GetAll()
                    .Where(x => x.C_CodEsc == codEsc && x.C_CodFac == codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }

        public IEnumerable<VW_CarreraProfesional> GetByFac(string codFac)
        {
            IEnumerable<VW_CarreraProfesional> result;
            try
            {
                result = VW_CarreraProfesional.GetAll()
                    .Where(x => x.C_CodFac == codFac);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }

        public VW_CarreraProfesional GetByID(string codRc)
        {
            VW_CarreraProfesional result;
            try
            {
                result = VW_CarreraProfesional.GetByID(codRc);
            }
            catch (Exception)
            {
                result = null;
            }
            return result;
        }
    }
}
