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
        public TC_Persona GetByDocIdent(string numDNI, string codTipDoc)
        {
            try
            {
                return TC_Persona.GetByDocIdent(numDNI, codTipDoc);
            }
            catch (Exception)
            {
                return null;
            }
        }

        public TC_Persona GetByID(int personaID)
        {
            try
            {
                return TC_Persona.GetByID(personaID);
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}
