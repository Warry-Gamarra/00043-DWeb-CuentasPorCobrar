using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories.Implementations
{
    public class PersonaRepository : IPersonaRepository
    {
        public IEnumerable<TC_Persona> GetByDocIdent(string codTipDoc, string numDNI)
        {
            IEnumerable<TC_Persona> result;
            try
            {
                result = TC_Persona.GetByDocIdent(codTipDoc, numDNI);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public TC_Persona GetByID(int personaID)
        {
            TC_Persona result;
            try
            {
                result = TC_Persona.GetByID(personaID);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}
