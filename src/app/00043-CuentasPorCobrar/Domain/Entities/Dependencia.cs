using Data.Tables;
using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class Dependencia : IDependencia
    {
        private readonly TC_DependenciaUNFV _dependenciaRepository;

        public int? Id { get; set; }
        public string Codigo { get; set; }
        public string CodigoPl { get; set; }
        public string Abreviatura { get; set; }
        public string Descripcion { get; set; }
        public bool EsAcademico { get; set; }
        public bool Habilitado { get; set; }

        public Dependencia()
        {
            _dependenciaRepository = new TC_DependenciaUNFV();
        }

        public Dependencia(TC_DependenciaUNFV tablaDependencia)
        {
            this.Id = tablaDependencia.I_DependenciaID;
            this.Codigo = tablaDependencia.C_DepCod;
            this.CodigoPl = tablaDependencia.C_DepCodPl;
            this.Descripcion = tablaDependencia.T_DepDesc;
            this.Habilitado = tablaDependencia.B_Habilitado;
        }


        public Response ChangeState(int dependenciaId, bool currentState, int currentUserId)
        {
            throw new NotImplementedException();
        }

        public List<Dependencia> Find()
        {
            var result = new List<Dependencia>();

            foreach (var item in _dependenciaRepository.Find())
            {
                result.Add(new Dependencia(item));
            }
            return result;
        }

        public Dependencia Find(int dependenciaId)
        {
            throw new NotImplementedException();
        }

        public Response Save(Dependencia dependencia, int currentUserId, SaveOption saveOption)
        {
            throw new NotImplementedException();
        }
    }
}
