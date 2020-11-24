using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.DTO;
using Data.Procedures;
using Data.Tables;

namespace Data.Repositories.Implementations
{
    public class CarreraProfesionalRepository : ICarreraProfesionalRepository
    {
        public ResponseData Create(TI_CarreraProfesional carreraProfesional)
        {
            USP_I_GrabarCarreraProfesional procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_I_GrabarCarreraProfesional()
                {
                    
                };

                result = procedimiento.Execute();
            }
            catch (Exception ex)
            {
                result = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public ResponseData Edit(TI_CarreraProfesional carreraProfesional)
        {
            USP_U_ActualizarCarreraProfesional procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_U_ActualizarCarreraProfesional()
                {

                };

                result = procedimiento.Execute();
            }
            catch (Exception ex)
            {
                result = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public IEnumerable<TI_CarreraProfesional> GetAll()
        {
            IEnumerable<TI_CarreraProfesional> result;
            try
            {
                result = TI_CarreraProfesional.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}
