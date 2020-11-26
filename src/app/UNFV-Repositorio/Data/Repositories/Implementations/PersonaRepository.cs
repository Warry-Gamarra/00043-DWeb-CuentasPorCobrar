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
    public class PersonaRepository : IPersonaRepository
    {
        public ResponseData Create(TC_Persona persona)
        {
            USP_I_GrabarPersona procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_I_GrabarPersona()
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

        public ResponseData Edit(TC_Persona persona)
        {
            USP_U_ActualizarPersona procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_U_ActualizarPersona()
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

        public IEnumerable<TC_Persona> GetAll()
        {
            try
            {
                return TC_Persona.GetAll();
            }
            catch (Exception)
            {
                return null;
            }
        }

        public TC_Persona GetByDocIdent(string C_NumDNI, string C_CodTipDoc)
        {
            try
            {
                return TC_Persona.GetByDocIdent(C_NumDNI, C_CodTipDoc);
            }
            catch (Exception)
            {
                return null;
            }
        }

        public TC_Persona GetByID(int I_PersonaID)
        {
            try
            {
                return TC_Persona.GetByID(I_PersonaID);
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}
