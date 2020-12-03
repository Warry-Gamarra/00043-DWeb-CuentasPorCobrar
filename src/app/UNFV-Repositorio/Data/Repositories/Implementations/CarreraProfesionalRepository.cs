using Data.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories.Implementations
{
    public class CarreraProfesionalRepository : ICarreraProfesionalRepository
    {
        public IEnumerable<VW_CarreraProfesional> GetAll(string codRc)
        {
            IEnumerable<VW_CarreraProfesional> result;
            try
            {
                result = VW_CarreraProfesional.GetAll();
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
