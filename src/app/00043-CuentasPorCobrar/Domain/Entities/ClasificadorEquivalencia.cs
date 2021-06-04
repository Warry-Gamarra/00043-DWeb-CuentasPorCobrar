using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ClasificadorEquivalencia : IClasificadorEquivalencia
    {
        public int? ClasificadorEquivId { get; set; }
        public int ClasificadorId { get; set; }
        public string ConceptoEquivCod { get; set; }
        public string ConceptoEquivDesc { get; set; }
        public string EspecificaCod { get; set; }
        public string CodClasificador { get; set; }
        public string Descripcion { get; set; }
        public string DescripDetalle { get; set; }
        public string AnioEjercicio { get; set; }
        public string CodigoUnfv { get; set; }
        public bool Habilitado { get; set; }
        public DateTime FecUpdated { get; set; }
        public Response Response { get; set; }

        private readonly TC_ClasificadorEquivalenciaAnio _clasificadorEquivAnioRepository;
        private readonly TC_ClasificadorEquivalencia _clasificadorEquivRepository;

        public ClasificadorEquivalencia()
        {
            _clasificadorEquivAnioRepository = new TC_ClasificadorEquivalenciaAnio();
            _clasificadorEquivRepository = new TC_ClasificadorEquivalencia();
        }

        public ClasificadorEquivalencia(TC_ClasificadorEquivalenciaAnio table)
        {
            this.ClasificadorEquivId = table.I_ClasifEquivalenciaID;
            this.ClasificadorId = table.I_ClasificadorID;
            this.ConceptoEquivCod = table.C_ClasificConceptoCod;
            this.ConceptoEquivDesc = table.T_ConceptoDesc;
            this.AnioEjercicio = table.N_Anio;
            this.Habilitado = table.B_Habilitado;
            this.Response = new Response() { Value = true };
        }

        public ClasificadorEquivalencia(TC_ClasificadorEquivalencia table)
        {
            this.ClasificadorEquivId = table.I_ClasifEquivalenciaID;
            this.ClasificadorId = table.I_ClasificadorID;
            this.ConceptoEquivCod = table.C_ClasificConceptoCod;
            this.ConceptoEquivDesc = table.T_ConceptoDesc;
            this.Response = new Response() { Value = true };
        }


        public List<ClasificadorEquivalencia> Find(string anio)
        {
            var result = new List<ClasificadorEquivalencia>();
            foreach (var item in _clasificadorEquivAnioRepository.Find(anio.ToString()))
            {
                result.Add(new ClasificadorEquivalencia(item));
            }

            return result;
        }

        public List<ClasificadorEquivalencia> Find(int clasificadorId)
        {
            var result = new List<ClasificadorEquivalencia>();
            foreach (var item in _clasificadorEquivRepository.Find(clasificadorId))
            {
                result.Add(new ClasificadorEquivalencia(item));
            }

            return result;
        }

        public List<ClasificadorEquivalencia> Find(int clasificadorId, string anio)
        {
            var result = new List<ClasificadorEquivalencia>();
            foreach (var item in _clasificadorEquivAnioRepository.Find(clasificadorId, anio))
            {
                result.Add(new ClasificadorEquivalencia(item));
            }

            return result;
        }

        public Response Save(ClasificadorEquivalencia clasificadorEquivalencia, int currentUserId, SaveOption saveOption)
        {
            _clasificadorEquivRepository.I_ClasifEquivalenciaID = clasificadorEquivalencia.ClasificadorEquivId.Value;
            _clasificadorEquivRepository.I_ClasificadorID = clasificadorEquivalencia.ClasificadorId;
            _clasificadorEquivRepository.C_ClasificConceptoCod = clasificadorEquivalencia.ConceptoEquivCod;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _clasificadorEquivRepository.D_FecCre = DateTime.Now;
                    return new Response(_clasificadorEquivRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _clasificadorEquivRepository.D_FecMod = DateTime.Now;
                    return new Response(_clasificadorEquivRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }

        public Response SaveAnio(ClasificadorEquivalencia clasificadorEquivalencia, string anio, int currentUserId, SaveOption saveOption)
        {

            _clasificadorEquivAnioRepository.I_ClasifEquivalenciaID = clasificadorEquivalencia.ClasificadorEquivId.Value;
            _clasificadorEquivAnioRepository.N_Anio = anio;
            _clasificadorEquivAnioRepository.B_Habilitado = clasificadorEquivalencia.Habilitado;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _clasificadorEquivAnioRepository.D_FecCre = DateTime.Now;
                    return new Response(_clasificadorEquivAnioRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _clasificadorEquivAnioRepository.D_FecMod = DateTime.Now;
                    return new Response(_clasificadorEquivAnioRepository.ChangeState(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }
    }
}
