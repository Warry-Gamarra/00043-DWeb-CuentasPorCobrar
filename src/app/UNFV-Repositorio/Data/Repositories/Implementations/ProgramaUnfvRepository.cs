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
    public class ProgramaUnfvRepository : IProgramaUnfvRepository
    {
        public ResponseData Create(TC_ProgramaUnfv programaUnfv)
        {
            USP_I_GrabarProgramaUnfv procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_I_GrabarProgramaUnfv()
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

        public ResponseData Edit(TC_ProgramaUnfv programaUnfv)
        {
            USP_U_ActualizarProgramaUnfv procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_U_ActualizarProgramaUnfv()
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

        public IEnumerable<TC_ProgramaUnfv> GetAll()
        {
            IEnumerable<TC_ProgramaUnfv> result;
            try
            {
                result = TC_ProgramaUnfv.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}
